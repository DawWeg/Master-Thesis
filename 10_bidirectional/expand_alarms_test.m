run("init.m");
global model_rank;
global alarm_expand;
model_rank = 4;
alarm_expand = 2;

test_cases = {...
    {...
      "Clear expand";...
      [ 0 0 0 0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0];... Detection
      [ 0 0 0 0 0 0 0 0 1 1 1 1 0 0 0 0 0 0 0];... Expected
    },...
    {...
      "No expand";...
      [ 0 0 0 0 0 0 0 1 1 0 0 0 0 1 1 0 0 0 0];... Detection
      [ 0 0 0 0 0 1 1 1 1 0 0 0 0 1 1 0 0 0 0];... Expected
    },...
        {...
      "Restricted expand";...
      [ 0 0 0 0 0 0 0 1 1 0 0 0 0 0 1 1 0 0 0];... Detection
      [ 0 0 0 0 0 1 1 1 1 0 0 0 0 1 1 1 0 0 0];... Expected
    },...
};

num_cases = size(test_cases,2);
for i=1:num_cases
  test_case = test_cases{i};
  [result] = expand_alarms_2(test_case{2});
  assert_equals(test_case{1}, test_case{3}, result);
endfor
