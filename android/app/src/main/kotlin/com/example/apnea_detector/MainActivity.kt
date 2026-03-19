package com.example.apnea_detector

import android.content.Context
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.records.OxygenSaturationRecord
import androidx.health.connect.client.units.Percentage
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.time.Instant
import java.time.ZoneId
import androidx.health.connect.client.records.metadata.Metadata as HcMetadata

class MainActivity : FlutterFragmentActivity() {

    private val channelName = "hc_bulk"
    private val ioScope = CoroutineScope(Dispatchers.IO)

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "insertOxygenSaturation" -> {
                        val args = call.arguments as? Map<*, *>
                        val samples = args?.get("samples") as? List<*>

                        if (samples == null) {
                            result.error("BAD_ARGS", "Missing 'samples'", null)
                            return@setMethodCallHandler
                        }

                        ioScope.launch {
                            try {
                                val inserted = insertOxygenSaturationBulk(applicationContext, samples)
                                withContext(Dispatchers.Main) { result.success(inserted) }
                            } catch (e: Exception) {
                                withContext(Dispatchers.Main) {
                                    result.error("HC_INSERT_FAILED", e.toString(), null)
                                }
                            }
                        }
                    }

                    else -> result.notImplemented()
                }
            }
    }

    private suspend fun insertOxygenSaturationBulk(
        context: Context,
        samples: List<*>
    ): Int {
        val client = HealthConnectClient.getOrCreate(context)

        val zoneOffset = ZoneId.systemDefault().rules.getOffset(Instant.now())

        val records = samples.mapNotNull { item ->
            val m = item as? Map<*, *> ?: return@mapNotNull null

            val timeMillis = (m["timeMillis"] as? Number)?.toLong() ?: return@mapNotNull null
            val value = (m["value"] as? Number)?.toDouble() ?: return@mapNotNull null

            val instant = Instant.ofEpochMilli(timeMillis)

            OxygenSaturationRecord(
                time = instant,
                zoneOffset = zoneOffset,
                percentage = Percentage(value),
                metadata = HcMetadata.manualEntry()
            )
        }

        client.insertRecords(records)

        return records.size
    }
}