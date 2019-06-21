package com.applicaster.player.plugins.brightcove.analytics

import android.view.View
import android.widget.Button
import com.applicaster.analytics.AnalyticsAgentUtil
import com.applicaster.plugin_manager.playersmanager.Playable
import com.brightcove.player.event.EventType
import com.brightcove.player.mediacontroller.buttons.CaptionsButtonController
import com.brightcove.player.view.BrightcoveVideoView

class CaptionsAnalyticsAdapter(
    private val view: BrightcoveVideoView
) : MorpheusAnalyticsAdapter(view), View.OnClickListener {

    private lateinit var brightcoveCaptionsButtonListener: View.OnClickListener
    private var captionsController: CaptionsButtonController? = null
    private var captionsButton: Button? = null
    private lateinit var playable: Playable
    private lateinit var mode: AnalyticsAdapter.PlayerMode
    private var previousState: CaptionsState = CaptionsState.OFF

    override fun startTrack(playable: Playable, mode: AnalyticsAdapter.PlayerMode) {
        this.playable = playable
        this.mode = mode
        initEventEmitter()
    }

    private fun initEventEmitter() {
        // register event emitter with "didSetSource" event type to obtain list of button controllers
        view.eventEmitter.on(EventType.DID_SET_SOURCE) {
            val buttonControllers = view.brightcoveMediaController.mediaControlRegistry.buttonControllers
            // finding CaptionsButtonController
            captionsController = buttonControllers.find {
                it is CaptionsButtonController
            } as? CaptionsButtonController
            // obtain list of buttons states and get from it captions button and it click listener
            captionsController?.stateList?.forEach {
                if (it.contentDescription == "Closed Captions") {
                    // get captions button view and click listener of this button
                    // and setup our custom click listener to this button
                    captionsButton = captionsController?.button
                    brightcoveCaptionsButtonListener = it.handler
                    // set our custom click listener to the Brightcove captions button
                    captionsButton?.setOnClickListener(this)
                }
            }
        }

        // this event is called when user change captions state(on/off)
        view.eventEmitter.on(EventType.TOGGLE_CLOSED_CAPTIONS) {
            val captionsState: Boolean? = it.properties["boolean"] as? Boolean
            captionsState?.let { state ->
                previousState = if (state) CaptionsState.ON else CaptionsState.OFF
            }
        }
    }

    /**
     * Whether the captions were previously on or off when the user tapped the closed captions icon
     */
    private fun getPreviousState(): Pair<String, String> = "Previous State" to previousState.value

    /**
     * Whether or not the stream requires a purchase voucher to access
     */
    private fun freeOrPaid() =
        when(playable.isFree) {
            true -> "Free or Paid" to "Free"
            false -> "Free or Paid" to "Paid"
        }

    /**
     * Collect all obtained parameters
     */
    private fun collectAnalyticsParams(): Map<String, String> =
        mapOf(
            getPreviousState(),
            getItemId(playable),
            getItemName(playable),
            getVideoType(),
            getViewMode(mode),
            getItemDuration(),
            getVODType(playable),
            freeOrPaid(),
            getTimecode()
        )

    // this one triggers when the user clicked Brightcove captions button with our custom listener
    override fun onClick(view: View?) {
        // just trigger Brightcove captions button listener to continue Brightcove player flow
        brightcoveCaptionsButtonListener.onClick(captionsButton)
        AnalyticsAgentUtil.logEvent("Tap Closed Captions", collectAnalyticsParams())
    }

    private enum class CaptionsState(val value: String) {
        ON(value = "On"), OFF(value = "Off")
    }
}