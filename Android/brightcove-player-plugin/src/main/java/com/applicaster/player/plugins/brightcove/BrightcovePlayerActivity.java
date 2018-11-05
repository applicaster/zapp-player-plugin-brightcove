package com.applicaster.player.plugins.brightcove;

import android.net.Uri;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import com.applicaster.plugin_manager.playersmanager.Playable;
import com.brightcove.player.view.BrightcoveVideoView;

import static com.applicaster.player.plugins.brightcove.BrightcovePlayerAdapter.KEY_PLAYABLE;

public class BrightcovePlayerActivity extends AppCompatActivity {

  private Playable playable;
  private BrightcoveVideoView videoView;

  @Override protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    requestWindowFeature(Window.FEATURE_NO_TITLE);
    getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
        WindowManager.LayoutParams.FLAG_FULLSCREEN);

    playable = (Playable) getIntent().getExtras().getSerializable(KEY_PLAYABLE);

    setContentView(R.layout.activity_brightcove_player);
    videoView = findViewById(R.id.video_view);
  }

  @Override protected void onStart() {
    super.onStart();
    if (playable != null) {
      videoView.setVideoURI(Uri.parse(playable.getContentVideoURL()));
      videoView.start();
    }
  }

  @Override public void onWindowFocusChanged(boolean hasFocus) {
    super.onWindowFocusChanged(hasFocus);
    if (hasFocus) {
      this.getWindow()
          .getDecorView()
          .setSystemUiVisibility(View.SYSTEM_UI_FLAG_LAYOUT_STABLE
              | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
              | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
              | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
              | View.SYSTEM_UI_FLAG_FULLSCREEN
              | View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY);
    }
  }
}
