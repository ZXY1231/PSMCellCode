%Initialize trackers based on the first_frame_bright_spot
function all_tracks = TrackerInitializaon(first_frame_bright_spots,t)
    all_tracks = cell(1,size(first_frame_bright_spots,1));
    for i  = 1:size(first_frame_bright_spots,1)
        all_tracks{i} = Tracker(i,first_frame_bright_spots(i,:),0,t);
    end
end