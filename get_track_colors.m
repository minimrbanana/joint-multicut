function track_colors = get_track_colors(num_tracks, rnd_seed)

  track_colors2 = hsv(3*num_tracks);

  rand('twister', rnd_seed);
  rp = randperm(size(track_colors2, 1));

  for idx = 1:num_tracks
    track_colors(idx, :) = track_colors2(rp(idx), :);
  end

  %disp(track_colors);
end
