function installDevTools()
% checks if the MATLAB.devTools are already present and installs the
% MATLAB.devTools next to the cloned folder cobratoolbox (if not present yet)
%
% USAGE:
%    installDevTools()
%
% NOTE:
%    In order to install the devTools, please make sure that the SSH key is
%    configured properly as explained `here`_.
%
% .. _here: https://opencobra.github.io/cobratoolbox/docs/solvers.html
%
% .. Author: Laurent Heirendt, June 2017

    global ENV_VARS
    global CBTDIR

    % make sure that The COBRA Toolbox is properly installed;
    % git and curl are tested here
    if isempty(ENV_VARS)
        ENV_VARS.printLevel = false;
        initCobraToolbox;
        ENV_VARS.printLevel = true;
    end

    currentDir = pwd;

    % change to the local directory
    localDir = [CBTDIR filesep '..'];
    cd(localDir);

    installFlag = false;

    % check if the devTools already exist
    if exist([CBTDIR filesep '..' filesep 'MATLAB.devTools'], 'dir') == 7

        reply = input([' > There is already a copy of the MATLAB.devTools installed in the default location.\n   Do you want to enter another location to install the MATLAB.devTools? Y/N [Y]: '], 's');
        localDir = '';

        if isempty(reply) || strcmpi(reply, 'y') || strcmpi(reply, 'yes')
        % enter another location for the MATLAB.devTools

            dirReply = '';
            while isempty(dirReply)
                dirReply = input(['\n -> Please define the installation path of the MATLAB.devTools\n    Enter the path: '], 's');

                if exist([dirReply filesep 'MATLAB.devTools'], 'dir') == 7
                    fprintf('\n   The directory ', [dirReply filesep 'MATLAB.devTools'], ' already exists. Please enter a different directory.\n');
                    dirReply = '';
                end

                if ~isempty(dirReply) && exist(dirReply, 'dir') == 7
                    localDir = dirReply;
                    break;
                else
                    fprintf('\n   -> The directory does not exist. Please try again.\n');
                    dirReply = '';
                end
            end

            installFlag = true;
        else
            installFlag = false;
            fprintf(' > You cannot install the MATLAB.devTools. Please delete the folder %s\n', [CBTDIR filesep '..' filesep 'MATLAB.devTools']);
        end
    else
        installFlag = true;
    end

    % install a new copy of the MATLAB.devTools
    if installFlag

        % changing to the local directory
        cd(localDir);

        % install the devTools properly speaking
        fprintf('\n > Installing the MATLAB.devTools (might take some time) ... ');

        [status_gitClone, result_gitClone] = system(['git clone -c http.sslVerify=false git@github.com:opencobra/MATLAB.devTools.git']);

        if status_gitClone == 0

            if ~isempty(localDir)
                indexDir = strfind(CBTDIR, filesep);
                devToolsDir = [CBTDIR(1:indexDir(end)), 'MATLAB.devTools'];
            else
                devToolsDir = dirReply;
            end

            fprintf(['Done.\n > Location of the MATLAB.devTools: ', strrep(devToolsDir, '\', '\\'), '\n\n']);

            % add the path to the devTools
            addpath(genpath(devToolsDir));

            % removing .git folder
            rmpath(genpath([devToolsDir filesep '.git']));

            fprintf([' > In order to start contributing, you can now run:\n\n >> contribute\n\n']);
        else
            fprintf(result_gitClone);
            error(['The MATLAB.devTools could not be cloned. Please make sure that your SSH key is configured correctly.']);
        end
    end

    % change back to the current directory
    cd(currentDir);
end
