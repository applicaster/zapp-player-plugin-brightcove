package com.applicaster.player.plugins.brightcove

import android.os.Bundle
import android.support.v4.app.DialogFragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.ImageButton
import android.content.Context
import android.net.ConnectivityManager
import android.widget.TextView
import com.google.gson.internal.LinkedTreeMap

interface ErrorDialogListener {

    /**
     *  Called when refresh button has clicked
     */
    fun onRefresh()

    /**
     *  Called when back or close button has clicked
     */
    fun onBack()
}

class ErrorDialog : DialogFragment(), View.OnClickListener {

    private lateinit var dialogType: ErrorDialogType
    private var errorListener: ErrorDialogListener? = null
    private var pluginConfigurationParams: LinkedTreeMap<*, *>? = null
    private var backButton: Button? = null
    private var refreshButton: Button? = null
    private var closeButton: ImageButton? = null
    private var tvDescription: TextView? = null


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        pluginConfigurationParams = this.arguments?.get(KEY_PLUGIN_CONFIGURATION) as? LinkedTreeMap<*, *>?

        // Check if Error dialog type is NETWORK_ERROR or VIDEO_PLAY_ERROR and set result to dialog type field
        dialogType = if (isNetworkAvailable())
            Companion.ErrorDialogType.VIDEO_PLAY_ERROR
        else
            Companion.ErrorDialogType.NETWORK_ERROR

        setStyle(STYLE_NO_FRAME, R.style.BrightcoveFullScreen_Theme)
        isCancelable = false
    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        // Create error dialog depending on the type of this dialog
        val view = when (dialogType) {
            Companion.ErrorDialogType.NETWORK_ERROR -> inflater.inflate(
                R.layout.fragment_error_dialog_network,
                container,
                false
            )
            else -> inflater.inflate(R.layout.fragment_error_dialog_video, container, false)
        }

        backButton = view.findViewById(R.id.btn_back)
        refreshButton = view.findViewById(R.id.btn_refresh)
        closeButton = view.findViewById(R.id.btn_error_view_close)
        tvDescription = view.findViewById(R.id.tv_description)

        backButton?.setOnClickListener(this)
        refreshButton?.setOnClickListener(this)
        closeButton?.setOnClickListener(this)

        configureView()

        return view
    }

    override fun onAttach(context: Context?) {
        if (errorListener == null)
            errorListener = context as? ErrorDialogListener?
        super.onAttach(context)
    }

    override fun onDetach() {
        errorListener = null
        super.onDetach()
    }

    override fun onClick(view: View?) {
        when (view?.id) {
            R.id.btn_back -> {
                errorListener?.onBack()
            }

            R.id.btn_refresh -> {
                errorListener?.onRefresh()
            }

            R.id.btn_error_view_close -> {
                errorListener?.onBack()
            }
        }
    }

    /**
     *  Sets plugin configuration parameters to view elements.
     *  If this parameters are empty - view elements use default parameters.
     */
    private fun configureView() {
        when (dialogType) {
            Companion.ErrorDialogType.NETWORK_ERROR -> {
                val buttonText = pluginConfigurationParams?.get(KEY_CONNECTIVITY_ERROR_BUTTON_TEXT) as? String
                if (buttonText != null) refreshButton?.text = buttonText

                val errorMessage =  pluginConfigurationParams?.get(KEY_CONNECTIVITY_ERROR_MESSAGE) as? String
                if (errorMessage != null) tvDescription?.text = errorMessage
            }

            Companion.ErrorDialogType.VIDEO_PLAY_ERROR -> {
                val buttonText = pluginConfigurationParams?.get(KEY_VIDEO_PLAY_ERROR_BUTTON_TEXT) as? String
                if (buttonText != null)  backButton?.text = buttonText

                val errorMessage =pluginConfigurationParams?.get(KEY_VIDEO_PLAY_ERROR_MESSAGE) as? String
                if (errorMessage != null) tvDescription?.text = errorMessage
            }
        }
    }

    /**
     *  Used for set listener from non Activity class.
     */
    fun setOnErrorDialogListener(errorDialogListener: ErrorDialogListener) {
        this.errorListener = errorDialogListener
    }

    /**
     *  Checks for network connection. Returns true if network connection is established.
     */
    fun isConnectionEstablished() = isNetworkAvailable()

    private fun isNetworkAvailable(): Boolean {
        val conMgr = this.context?.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        return (conMgr.activeNetworkInfo != null
                && conMgr.activeNetworkInfo.isAvailable
                && conMgr.activeNetworkInfo.isConnected)
    }

    companion object {

        private const val KEY_PLUGIN_CONFIGURATION = "plugin_configuration"
        private const val KEY_VIDEO_PLAY_ERROR_MESSAGE = "GeneralVideoPlayErrorMessage"
        private const val KEY_VIDEO_PLAY_ERROR_BUTTON_TEXT = "GeneralVideoPlayErrorButtonText"
        private const val KEY_CONNECTIVITY_ERROR_MESSAGE = "ConnectivityErrorMessage"
        private const val KEY_CONNECTIVITY_ERROR_BUTTON_TEXT = "ConnectivityErrorButtonText"

        /**
         *  Creates a new instance of this dialog and returns it.
         */
        fun newInstance(pluginConfigurationParams: Map<*, *>): ErrorDialog {
            val dialog = ErrorDialog()
            val bundle = Bundle()
            bundle.apply {
                putSerializable(KEY_PLUGIN_CONFIGURATION, pluginConfigurationParams as LinkedTreeMap<*, *>)
            }
            dialog.arguments = bundle
            return dialog
        }

        /**
         *  Type of ErrorDialog
         */
        enum class ErrorDialogType {
            NETWORK_ERROR,
            VIDEO_PLAY_ERROR
        }
    }
}