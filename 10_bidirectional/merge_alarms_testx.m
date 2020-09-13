function [dfb] = merge_alarms_testx(df, db)
    global model_rank alarm_expand max_corrupted_block_length;
    % Prepare expanded signals
    ex_df = expand_alarms_2(df);
    ex_db = flip(expand_alarms_2(flip(db)));
    
    % Initialize parameters
    dfb = zeros(size(df));
    N = length(df);
    r = model_rank;
    max_alarm = max_corrupted_block_length;



    % Split for analytic windows (assume window numer == sample count)
    analytic_windows = zeros(2,N);
    analytic_windows_count = 0;

    clear_samples = model_rank;
    window_started = 0;

    for i=1+model_rank:N
      print_progress("Creating analytic windows", i, N, N/10);
      % Check status of both forward and backward detection
      detected = ex_db(i) || ex_df(i);
      if window_started
            % If inside new analytic window
            if detected
                  % -> Sample corrupter? Zero clear_samples counter
                  clear_samples = 0;
            else
                  % -> Sample ok ? Increase clear_samples counter and check if full window found
                  clear_samples++;
                  if clear_samples == r
                    % Full window found ? save it and increase counter
                    window_started = 0;
                    analytic_windows(2, analytic_windows_count+1) = i;
                    analytic_windows_count++;
                  endif
            endif    
      else
            % If not inside analytic_window
            if detected && clear_samples >= r
              % Start new analytic window
              window_started = 1;
              analytic_windows(1, analytic_windows_count+1) = i;
            elseif detected
              % this situation should not happen
              disp("I SHOULD NOT BE HERE -> Analytic window problem");
            endif
      endif
    endfor
    print_progress("Creating analytic windows", N, N, N/10);

    analytic_windows = analytic_windows(:, 1:analytic_windows_count);
    printf("Found %f separate analytic windows\n", analytic_windows_count);
    a_counter = 0;
    b_counter = 0;
    c_counter = 0;
    d_counter = 0;
    for i=1:analytic_windows_count
      window=analytic_windows(:,i);
      print_progress("Merging alarms in window", i, analytic_windows_count, analytic_windows_count/100);
      wnd_start = window(1);
      wnd_end = window(2);
      
      % Find or forward and backward detected alarms in current window
      f_alarms = find_alarms_in_range(ex_df, wnd_start, wnd_end);
      f_alarms_count = size(f_alarms, 2);
      b_alarms = find_alarms_in_range(ex_db, wnd_start, wnd_end);
      b_alarms_count = size(b_alarms, 2);
      
      if f_alarms_count == 0 
        % No forward alarms -> Class C for backward
        c_counter++;
        b_start = b_alarms(1,1);
        b_end = b_alarms(2,1);
        % Let's find original ending:
        b_org_end = b_end;
        while db(b_org_end) != ex_db(b_org_end)
          b_org_end--;
        endwhile
        
        if i > 1
          % If this is not the first window we need to check if expand is possible
          previoues_window_end = analytic_windows(2,i-1);
          if previoues_window_end + r < b_org_end - alarm_expand
            % Expand is possible with specified expand
            dfb(b_org_end-alarm_expand:b_end) = 1;
          else 
            % Expand is not possible, calculate highest possible value
            possible_expand = b_org_end - (previoues_window_end + r);
            dfb(b_org_end-possible_expand:b_end) = 1;
          endif
        else
          % First window, no alarms before
          dfb(b_org_end-alarm_expand:b_end) = 1;
        endif
      elseif b_alarms_count == 0
        % No backward alarms -> Class C for forward
        c_counter++;
        f_start = f_alarms(1,1);
        f_end = f_alarms(2,1);
        % Let's find original ending:
        f_org_start = f_start;
        while df(f_org_start) != ex_df(f_org_start)
          f_org_start++;
        endwhile
        
        
        if i < analytic_windows_count
          % This is not the last window, we need to check if expand is possible
          next_window_start = analytic_windows(1,i+1);
          if next_window_start - r > f_org_start + alarm_expand
            % Expand is possible with current setting
            dfb(f_start:f_org_start+alarm_expand) = 1;
          else 
            % Recalculate expand 
            possible_expand = (next_window_start - r) - f_org_start;
            dfb(f_start:f_org_start+alarm_expand) = 1;
          endif
        else
          % Last window, no alarms after
          dfb(f_start:f_org_start+alarm_expand) = 1;
        endif
      elseif  f_alarms_count > 1 || b_alarms_count > 1
        % More than 2 alarms in window -> D Class
        d_counter++;
        f_start = f_alarms(1,1);
        b_end = b_alarms(2,end);
        % For better results instead of -> f_start:b_end
        % We try to find overlapping alarms (configuartion A) on all alarms in window
        for i=1:f_alarms_count
          f_temp_start = f_alarms(1,i);
          f_temp_end = f_alarms(2,i);
          for j=1:b_alarms_count
            b_temp_start = b_alarms(1,j);
            b_temp_end = b_alarms(2,j);
            % Check for overlaps
            if !(f_temp_end < b_temp_start || b_temp_end < f_temp_start)
              fb_start = f_temp_start;
              fb_end = b_temp_end;
              dfb(fb_start:fb_end) = 1;
            endif
          endfor
        endfor
        % To keep separation we need to fill detection signals for "false positives"
        % Which means correct samples that count does not exceed model rank
        [dfb(f_start:b_end), ~] = fill_detection(dfb(f_start:b_end), model_rank);
        
        if (b_end-f_start > max_corrupted_block_length)
          % Here we can do handling of potential too long alarms 
          printf("Alarm longer than max! %f\n", b_end-f_start );
        endif
      else 
        % Let's check for A or B class
        f_start = f_alarms(1,1);
        f_end = f_alarms(2,1);
        b_start = b_alarms(1,1);
        b_end = b_alarms(2,1);
        if f_end < b_start || b_end < f_start
          % B Class
          b_counter++;
          fb_start = min([f_start, b_start]);
          fb_end = max([f_end, b_end]);
          dfb(fb_start:fb_end) = 1;
        else 
          % A Class
          a_counter++;
          fb_start = f_start;
          fb_end = b_end;
          dfb(fb_start:fb_end) = 1;
        endif
      endif
      
    endfor
    print_progress("Merging alarms in window",  analytic_windows_count, analytic_windows_count, analytic_windows_count/100);
    printf("A: %f | B: %f | C: %f | D: %f\n", a_counter, b_counter, c_counter, d_counter);

endfunction
