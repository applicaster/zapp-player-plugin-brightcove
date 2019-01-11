package com.applicaster.player.plugins.zapppluginplayerexampleandroid;

import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v7.app.AppCompatActivity;
import android.view.View;
import android.widget.Button;
import android.widget.FrameLayout;
import com.applicaster.atom.model.APAtomEntry;
import com.applicaster.model.APURLPlayable;
import com.applicaster.plugin_manager.playersmanager.PlayerContract;
import com.applicaster.plugin_manager.playersmanager.internal.PlayableType;
import com.applicaster.plugin_manager.playersmanager.internal.PlayersManager;
import com.applicaster.util.UrlSchemeUtil;

/**
 * This sample activity will create a player contract which will create an instance of your player
 * and pass it a sample playable item. From there you have options to launch full screen or attach
 * inline.
 * This is for testing your implementation against the Zapp plugin system.
 * <p>
 * Note: You must have your player plugin module in this project and the appropriate plugin
 * manifest
 * in the plugin_configurations.json
 */
public class MainActivity extends AppCompatActivity implements View.OnClickListener {
    private static final String TEST_AD_DATA =
            "{\"video_ad\":[{\"ad_url\":\"https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/single_ad_samples&ciu_szs=300x250&impl=s&gdfp_req=1&env=vp&output=vast&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ct%3Dlinear&correlator=\",\"offset\":\"pre\"}" +
                    ",{\"ad_url\":\"https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/single_ad_samples&ciu_szs=300x250&impl=s&gdfp_req=1&env=vp&output=vast&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ct%3Dredirectlinear&correlator=\",\"offset\":\"post\"}" +
                    ",{\"ad_url\":\"https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/single_ad_samples&ciu_szs=300x250&impl=s&gdfp_req=1&env=vp&output=vast&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ct%3Dskippablelinear&correlator=\",\"offset\":\"30\"}" +
                    ",{\"ad_url\":\"https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/single_ad_samples&ciu_szs=300x250&impl=s&gdfp_req=1&env=vp&output=vast&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ct%3Dskippablelinear&correlator=\",\"offset\":\"90\"}" +
                    "]}";

    Button fullScreenButton;
    Button inlineButton;
    private FrameLayout videoLayout;
    private boolean inlineAttached = false;
    private PlayerContract playerContract;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        videoLayout = findViewById(R.id.video_layout);

        fullScreenButton = findViewById(R.id.fullscreen_button);
        inlineButton = findViewById(R.id.inline_button);

        fullScreenButton.setOnClickListener(this);
        inlineButton.setOnClickListener(this);

        // Mock playable item. Replace this with the playable item your player expects
        APURLPlayable playable =
                new APURLPlayable("http://media.w3.org/2010/05/sintel/trailer.mp4",
                        "Buck Bunny",
                        "Test Video");
        // Mock playable item with ads. Use it instead of APURLPlayable to check how ad will work
//        APAtomEntry.APAtomEntryPlayable playable = getPlayableWithAds();

        // Player type should be left as default (covers the standard player as well as all plugin players)
        playable.setType(PlayableType.Default);

        // Player contract will get the instance of your plugin player and pass it the playable item
        playerContract = PlayersManager.getInstance().createPlayer(playable, this);
    }

    @Override
    public void onClick(View view) {
        switch (view.getId()) {
            case R.id.fullscreen_button: {
                launchFullscreen();
            }
            break;
            case R.id.inline_button: {
                toggleInline();
            }
            break;
        }
    }

    /**
     * Mimics the functionality of launching a fullscreen player in the Zapp platform
     * This should not be modified
     */
    private void launchFullscreen() {
        playerContract.playInFullscreen(null, UrlSchemeUtil.PLAYER_REQUEST_CODE, this);
    }

    /**
     * Mimics the functionality of adding or removing an inline player in the Zapp platform
     * This should not be modified
     */
    private void toggleInline() {
        if (!inlineAttached) {
            inlineButton.setText("Remove Inline");
            inlineAttached = true;
            playerContract.attachInline(videoLayout);
            playerContract.playInline(null);
        } else {
            inlineButton.setText("Play Inline");
            inlineAttached = false;
            playerContract.stopInline();
            playerContract.removeInline(videoLayout);
        }
    }

    /**
     * Generate mock playable item with ads
     */
    @NonNull
    private APAtomEntry.APAtomEntryPlayable getPlayableWithAds() {
        APAtomEntry entry = new APAtomEntry();
        entry.setExtension("video_ads", TEST_AD_DATA);
        APAtomEntry.Content content = new APAtomEntry.Content();
        content.src = "http://media.w3.org/2010/05/sintel/trailer.mp4";
        entry.setContent(content);
        entry.setTitle("Buck Bunny");
        return new APAtomEntry.APAtomEntryPlayable(entry);
    }
}
