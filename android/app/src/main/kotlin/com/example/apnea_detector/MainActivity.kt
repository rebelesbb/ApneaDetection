package com.example.apnea_detector

import android.content.Context
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.records.OxygenSaturationRecord
import androidx.health.connect.client.units.Percentage
import androidx.health.connect.client.records.SleepSessionRecord
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

                    "insertSleepSession" -> {
                        val args = call.arguments as? Map<*, *>

                        if (args == null) {
                            result.error("BAD_ARGS", "Missing args", null)
                            return@setMethodCallHandler
                        }

                        ioScope.launch {
                            try {
                                val inserted = insertSleepSession(
                                    applicationContext,
                                    args
                                )

                                withContext(Dispatchers.Main) {
                                    result.success(inserted)
                                }
                            } catch (e: Exception) {
                                withContext(Dispatchers.Main) {
                                    result.error(
                                        "HC_SLEEP_INSERT_FAILED",
                                        e.toString(),
                                        null
                                    )
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

    private suspend fun insertSleepSession(
        context: Context,
        args: Map<*, *>
    ): Int {
        val client = HealthConnectClient.getOrCreate(context)

        val startMillis = (args["startMillis"] as? Number)?.toLong()
            ?: throw IllegalArgumentException("Missing startMillis")

        val endMillis = (args["endMillis"] as? Number)?.toLong()
            ?: throw IllegalArgumentException("Missing endMillis")

        val rawStages = args["stages"] as? List<*>
            ?: emptyList<Any>()

        val sessionStart = Instant.ofEpochMilli(startMillis)
        val sessionEnd = Instant.ofEpochMilli(endMillis)

        if (!sessionEnd.isAfter(sessionStart)) {
            throw IllegalArgumentException("Sleep session end must be after start")
        }

        val startZoneOffset = ZoneId.systemDefault().rules.getOffset(sessionStart)
        val endZoneOffset = ZoneId.systemDefault().rules.getOffset(sessionEnd)

        val stages = rawStages
            .mapNotNull { item ->
                val m = item as? Map<*, *> ?: return@mapNotNull null

                val stageStartMillis = (m["startMillis"] as? Number)?.toLong()
                    ?: return@mapNotNull null

                val stageEndMillis = (m["endMillis"] as? Number)?.toLong()
                    ?: return@mapNotNull null

                val stageName = m["stage"]?.toString()?.trim()
                    ?: return@mapNotNull null

                val stageStart = Instant.ofEpochMilli(stageStartMillis)
                val stageEnd = Instant.ofEpochMilli(stageEndMillis)

                if (!stageEnd.isAfter(stageStart)) {
                    return@mapNotNull null
                }

                val clippedStart = maxInstant(stageStart, sessionStart)
                val clippedEnd = minInstant(stageEnd, sessionEnd)

                if (!clippedEnd.isAfter(clippedStart)) {
                    return@mapNotNull null
                }

                SleepSessionRecord.Stage(
                    startTime = clippedStart,
                    endTime = clippedEnd,
                    stage = mapCsvStageToHealthConnectStage(stageName)
                )
            }
            .sortedBy { it.startTime }

        validateNoStageOverlap(stages)

        val record = SleepSessionRecord(
            startTime = sessionStart,
            startZoneOffset = startZoneOffset,
            endTime = sessionEnd,
            endZoneOffset = endZoneOffset,
            title = "Test sleep session",
            notes = "Imported from CSV",
            stages = stages,
            metadata = HcMetadata.manualEntry()
        )

        client.insertRecords(listOf(record))

        return 1
    }

    private fun mapCsvStageToHealthConnectStage(stage: String): Int {
        return when (stage.uppercase()) {
            // Wake
            "W", "0", "AWAKE" ->
                SleepSessionRecord.STAGE_TYPE_AWAKE

            // N1 + N2 -> Light sleep
            "N1", "1", "N2", "2", "LIGHT" ->
                SleepSessionRecord.STAGE_TYPE_LIGHT

            // N3 -> Deep sleep
            "N3", "3", "DEEP" ->
                SleepSessionRecord.STAGE_TYPE_DEEP

            // REM
            "R", "REM", "4" ->
                SleepSessionRecord.STAGE_TYPE_REM

            else ->
                SleepSessionRecord.STAGE_TYPE_UNKNOWN
        }
    }

    private fun validateNoStageOverlap(stages: List<SleepSessionRecord.Stage>) {
        for (i in 0 until stages.size - 1) {
            val current = stages[i]
            val next = stages[i + 1]

            if (current.endTime.isAfter(next.startTime)) {
                throw IllegalArgumentException(
                    "Sleep stages overlap: ${current.startTime}-${current.endTime} " +
                        "overlaps ${next.startTime}-${next.endTime}"
                )
            }
        }
    }

    private fun maxInstant(a: Instant, b: Instant): Instant {
        return if (a.isAfter(b)) a else b
    }

    private fun minInstant(a: Instant, b: Instant): Instant {
        return if (a.isBefore(b)) a else b
    }
}