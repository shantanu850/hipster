/*
 * Copyright (c) 2025 Duong Le. MIT License.
 */

package com.retozu.flutter_amazon_chime

import com.amazonaws.services.chime.sdk.meetings.analytics.EventAnalyticsObserver
import com.amazonaws.services.chime.sdk.meetings.analytics.EventAttributes
import com.amazonaws.services.chime.sdk.meetings.analytics.EventName

class ChimeEventAnalyticsObserver(private val chimeFlutterApi: ChimeFlutterApi) : EventAnalyticsObserver {
    override fun onEventReceived(name: EventName, attributes: EventAttributes) {
        val stringAttributes: Map<String?, Any?> = attributes.entries.associate { (key, value) -> 
            val safeValue = when (value) {
                is String, is Boolean, is Number, null -> value
                else -> value.toString()
            }
            key.name to safeValue 
        }
        chimeFlutterApi.onMeetingEventReceived(name.name, stringAttributes) {}
    }
}
