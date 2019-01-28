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

interface ErrorDialogListener {

    /**
     *  Called when user has been pressed refresh button
     */
    fun onRefresh()

    /**
     *  Called when user has been pressed back or close button
     */
    fun onBack()
}

class ErrorDialog : DialogFragment(), View.OnClickListener {

    private lateinit var dialogType: ErrorDialogType
    private var errorListener: ErrorDialogListener? = null


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Check if Error dialog type is NETWORK_ERROR or VIDEO_PLAY_ERROR and set result to dialog type field
        dialogType = if (isNetworkAvailable())
            Companion.ErrorDialogType.VIDEO_PLAY_ERROR
        else Companion.ErrorDialogType.NETWORK_ERROR

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

        val backButton: Button? = view.findViewById(R.id.btn_back)
        val refreshButton: Button? = view.findViewById(R.id.btn_refresh)
        val closeButton: ImageButton? = view.findViewById(R.id.btn_error_view_close)


        backButton?.setOnClickListener(this)
        refreshButton?.setOnClickListener(this)
        closeButton?.setOnClickListener(this)

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

        /**
         *  Creates a new instance of this dialog and returns it.
         */
        fun newInstance() = ErrorDialog()

        /**
         *  Type of ErrorDialog
         */
        enum class ErrorDialogType {
            NETWORK_ERROR,
            VIDEO_PLAY_ERROR
        }
    }
}