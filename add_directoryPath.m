function add_directoryPath( )
	%% Get the name of current directory
    cur_path = pwd; % current directory
	% cur_path = fileparts( which( mfilename ) );
	addpath(genpath(cur_path));
end
