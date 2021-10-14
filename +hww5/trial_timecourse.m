function [tcourse, tcourse_labels, bin_t] = trial_timecourse(data, labels, mask, each, bin_size, bin_step)

I = findall_or_one( labels, each, mask );
tcourse = [];
tcourse_labels = fcat;

for i = 1:numel(I)
  dat = data(I{i}, :);  
  ind = shared_utils.vector.slidebin( 1:size(dat, 1), bin_size, bin_step );
  mus = cellfun( @(x) nanmean(dat(x)), ind );
  
  if ( numel(mus) > size(tcourse, 2) )
    tmp = tcourse;
    tcourse = nan( size(tcourse, 1), numel(mus) );
    tcourse(1:size(tmp, 1), 1:size(tmp, 2)) = tmp;
    bin_t = cellfun( @(x) x(1), ind );
  end
  
  tcourse(end+1, :) = nan;
  tcourse(end, 1:numel(mus)) = mus;
  append1( tcourse_labels, labels, I{i} );
end

assert_ispair( tcourse, tcourse_labels );
assert( size(tcourse, 2) == numel(bin_t) );

end