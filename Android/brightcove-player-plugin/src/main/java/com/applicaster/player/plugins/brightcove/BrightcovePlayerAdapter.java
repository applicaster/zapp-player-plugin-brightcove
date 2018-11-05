package com.applicaster.player.plugins.brightcove;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.view.ViewGroup;
import com.applicaster.player.defaultplayer.BasePlayer;
import com.applicaster.plugin_manager.playersmanager.Playable;
import com.applicaster.plugin_manager.playersmanager.PlayableConfiguration;
import com.brightcove.player.view.BrightcoveExoPlayerVideoView;
import com.brightcove.player.view.BrightcoveVideoView;
import java.util.Arrays;
import java.util.List;

/**
 * BrightcovePlayerAdapter.java:
 * This adapter extends the BasePlayer class which implements the PlayerContract.
 * This class includes the various initialization methods as well as several playback methods.
 */
public class BrightcovePlayerAdapter extends BasePlayer {

  static final String KEY_PLAYABLE = "playable";
  private BrightcoveVideoView videoView;
  private boolean allowPortrait = false;

  /**
   * initialization of the player instance with a playable item
   */
  @Override public void init(Playable playable, Context context) {
    this.init(Arrays.asList(playable), context);
  }

  /**
   * initialization of the player instance with  multiple playable items
   */
  @Override public void init(List<Playable> playList, Context context) {
    super.init(playList, context);
    videoView = new BrightcoveExoPlayerVideoView(context);
  }

  /**
   * start the player in fullscreen with configuration.
   *
   * @param playableConfiguration player configuration.
   * @param requestCode request code if needed - if not send NO_REQUEST_CODE instead.
   */
  @Override public void playInFullscreen(PlayableConfiguration playableConfiguration,
      int requestCode, Context context) {
    super.playInFullscreen(playableConfiguration, requestCode, context);
    Intent intent = new Intent(context, BrightcovePlayerActivity.class);
    if (getFirstPlayable() != null) {
      intent.putExtra(KEY_PLAYABLE, getFirstPlayable());
      intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
      context.startActivity(intent);
    }
  }

  /**
   * Add the player into the given container.
   *
   * @param viewGroup The container the player should be added to
   */
  @Override public void attachInline(ViewGroup viewGroup) {
    super.attachInline(viewGroup);
    if (videoView != null) {
      viewGroup.addView(videoView);
      videoView.finishInitialization();
    }
  }

  /**
   * Remove the player from it's container.
   *
   * @param viewGroup The container that the player is attached to
   */
  @Override public void removeInline(ViewGroup viewGroup) {
    super.removeInline(viewGroup);
    if (videoView != null) {
      viewGroup.removeView(videoView);
    }
  }

  /**
   * start the player in inline with configuration.
   */
  @Override public void playInline(PlayableConfiguration configuration) {
    super.playInline(configuration);
    if (getFirstPlayable() == null) {
      return;
    }
    videoView.setVideoURI(Uri.parse(getFirstPlayable().getContentVideoURL()));
    videoView.start();
  }

  /**
   * Stops playing the inline player.
   */
  @Override public void stopInline() {
    super.stopInline();
    if (videoView != null) {
      videoView.stopPlayback();
    }
  }

  /**
   * Pauses playing the inline player
   */
  @Override public void pauseInline() {
    super.pauseInline();
    if (videoView != null) {
      videoView.pause();
    }
  }

  /**
   * Resumes playing the inline player.
   */
  @Override public void resumeInline() {
    super.resumeInline();
    if (videoView != null) {
      videoView.start();
    }
  }
}
