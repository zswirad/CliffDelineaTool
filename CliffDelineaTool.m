% CliffDelineaTool
% https://github.com/zswirad/CliffDelineaTool
% Zuzanna M Swirad (zswirad@ucsd.edu), Scripps Institution of Oceanography, UC San Diego
% Last updated on 2021-06-23 (MATLAB R2019a)

clear all

% Indicate input data parameters:
myFolder = 'C:\data'; % Change accordingly
filePattern = fullfile(myFolder, '*.txt');
theFiles = dir(filePattern);
delimiterIn = ',';
headerlinesIn = 1;
c1 = 1; % Column containing point ID
c2 = 2; % Column containing transect ID
c3 = 4; % Column containing distance from the seaward end
c4 = 3; % Column containing elevation

% Set the calibrated input variables:
NVert = 10; % How many adjacent points to consider as a local scale?
BaseMaxElev = 5; % What is the top limit for cliff base elevation (m)?
TopSea = 30; % What is the max seaward slope at the cliff top (deg)?
TopLand = 20; % What is the min landward slope at the cliff top (deg)?
PropConvex = 0.35; % What is the minimal proportion of the distance from trendline #2 to replace modelled cliff top location in case of composed cliff profile (0-1)?
SmoothWindow = 5; % What is the alongshore moving window for cross-shore cliff top smoothing (points)?

for k = 1:size(theFiles,1)
    clear sub
    clear data
    clear modelled_base
    clear modelled_top
    clear table
    
    baseFileName = theFiles(k).name;
    baseFileName
    fullFileName = fullfile(myFolder, baseFileName);
    base = baseFileName([1:end-4]);
    data = importdata(fullFileName,delimiterIn,headerlinesIn);
    data=data.data;
    
    dataTemp = data(:,c1);
    dataTemp(:,2) = data(:,c2);
    dataTemp(:,3) = data(:,c3);
    dataTemp(:,4) = data(:,c4);
    dataTemp(dataTemp<-50) = NaN;
    data = dataTemp;
    clear dataTemp

    % Add information about local slopes and deviation from a straight line:
    countRows=0;
    
    for n = min(data(:,2)):max(data(:,2)) 
        sub = data(data(:,2)==n,:);
        if size(sub,1) > 0
            sub = (sortrows(sub,3));
            elev = sub(:,4);
            
            % Fill data gaps:
            % 1. Extrapolate elevations at transect peripheries:
            valueFirst = find(elev>-50,1,'first');
            valueLast = find(elev>-50,1,'last');
            sub(1:valueFirst,4) = sub(valueFirst,4);
            sub(valueLast:end,4) = sub(valueLast,4);

            % 2. Interpolate elevations:
            if size(valueFirst) > 0
                sum_nan = sum(isnan(elev(valueFirst:end)));
                if sum_nan ~= 0
                    for m = valueFirst:size(sub,1)
                        if isnan(sub(m,4))
                            for p = (m+1):size(sub,1)
                                if sub(p,4) > -500
                                    break;
                                end
                            end    
                            dist = (sub(m,3)-sub(m-1,3))/(sub(p,3)-sub(m-1,3));
                            sub(m,4) = sub(m-1,4)+dist*(sub(p,4)-sub(m-1,4));
                        end
                    end
                end
            end

            % Calculate local slopes:            
            sub(:,5:8) = zeros;
            for z = (NVert+1):(size(sub,1)-NVert)
                count = 0;
                for s = 1:NVert
                    if sub(z,4) ~= sub(z-s,4)
                        angle = radtodeg(atan((sub(z,4) - sub(z-s,4))/(sub(z,3) - sub(z-s,3))));
                        if angle < 0
                            angle = 0;
                        end
                        sub(z,5) = sub(z,5) + angle;
                        count = count + 1;
                    end
                end
                % Seaward slope = average slope between the point and NVert consecutive seaward points:
                sub(z,5) = sub(z,5)/count;

                count = 0;
                for s = 1:NVert
                    if sub(z,4) ~= sub(z+s,4)
                        angle = radtodeg(atan((sub(z+s,4) - sub(z,4))/(sub(z+s,3) - sub(z,3))));
                        if angle < 0
                            angle = 0;
                        end
                        sub(z,6) = sub(z,6) + angle;
                        count = count + 1;
                    end
                end
                % Landward slope = average slope between the point and NVert consecutive landward points:
                sub(z,6) = sub(z,6)/count;
            end

            % Limit the transect landwards to the higest point + NVert:
            [maxElev, indMax] = max(sub(:,4));
            if size(sub,1) > indMax + NVert
                sub((indMax+NVert+1):end,:) = [];
            end

            % Draw trendline #1 (straight line between the seaward and landward transect ends):
            sub(1,7) = sub(1,4);
            sub(end,7) = sub(end,4);
            for z = 2:(size(sub,1)-1)
                sub(z,7) = (sub(z,3)-sub(1,3))*(sub(end,4)-sub(1,4))/(sub(end,3)-sub(1,3))+sub(1,4);
            end
            
            % Calculate vertical distance between actual elevations and trendline #1:
            sub(:,8) = sub(:,4)-sub(:,7);
            
            table((countRows+1):(countRows+size(sub,1)),:) = sub;
            countRows = size(table,1);
        end
    end
    
    % Find potential cliff base locations:
    base_count = 0;
    potential_base = zeros(0,8);
    for n = 1:size(table,1)
        if table(n,4) < BaseMaxElev && table(n,8) < 0
            potential_base(base_count+1,:) = table(n,:);
            base_count = base_count+1;
        end
    end
   
    % From the points that satisfy the criteria, for each transect select
    % one with the largest vertical difference between the elevation and trendline #1:
    if size(potential_base,1) > 0
        count = 0;
        modelled_base = zeros(0,8);
        cliffed_profiles = unique(potential_base(:,2));
        for n = min(potential_base(:,2)):max(potential_base(:,2))
            for m = 1:size(cliffed_profiles)
                if n == cliffed_profiles(m)
                    sub = potential_base(potential_base(:,2)==n,:);
                    sub = sortrows(sub,8);
                    modelled_base(count+1,:) = sub(1,:);
                    count = count+1;
                end
            end
        end
    end

    % Find cliff top locations for transects with cliff base:
    if size(modelled_base,1) > 0
        count = 0;
        modelled_top = zeros(0,10);
        for n = min(modelled_base(:,2)):max(modelled_base(:,2))
            for c = 1:size(cliffed_profiles)
                if n == cliffed_profiles(c)
                    sub = table(table(:,2)==n,:);

                    % Remove points seawards from the cliff base:
                    for m = 1:size(modelled_base,1)
                        if modelled_base(m,2) == n
                           sub_base = modelled_base(m,:);
                        end
                    end
                    sub = sortrows(sub,3);
                    sub(sub(:,3) < sub_base(3),:)=[];

                    % Draw trendline #2 between cliff base and landward transect end:
                    sub(:,9) = 0;
                    sub(1,9) = sub(1,4);
                    sub(end,9) = sub(end,4);
                    for z = 2:(size(sub,1)-1)
                        sub(z,9) = (sub(z,3)-sub(1,3))*(sub(end,4)-sub(1,4))/(sub(end,3)-sub(1,3))+sub(1,4);
                    end 
                    sub(:,10) = sub(:,4)-sub(:,9);

                    % Find potential cliff top locations:
                    top_count = 0;
                    potential_top = zeros(0,10);
                    for m = 1:size(sub,1)
                        if sub(m,5) > TopSea && sub(m,6) < TopLand && sub(m,10) > 0
                            potential_top(top_count+1,:) = sub(m,:);
                            top_count = top_count+1;
                        end
                    end
                    
                    if size(potential_top,1) > 0
                        potential_top = sortrows(potential_top,10);

                        % From the points that satisfy the criteria, for each transect select
                        % one with the largest vertical difference between the elevation and trendline #2:
                        modelled_top0 = potential_top(end,:);

                        % Check whether the selected point is part of within-cliff flattening: 
                        if max(potential_top(:,3)) > potential_top(end,3) + NVert       
                            subNew = sub;
                            subNew(subNew(:,3) < potential_top(end,3),:) = [];
                            subNew(:,11:12) = zeros;                        
                            subNew(1,11) = subNew(1,4);
                            subNew(end,11) = subNew(end,4);
                            for z = 2:(size(subNew,1)-1)
                                subNew(z,11) = (subNew(z,3)-subNew(1,3))*(subNew(end,4)-subNew(1,4))/(subNew(end,3)-subNew(1,3))+subNew(1,4);
                            end 
                            subNew(:,12) = subNew(:,4) - subNew(:,11);

                            potential_top2 = potential_top;
                            potential_top2(potential_top2(:,3) < potential_top(end,3),:) = [];
                            potential_top2(:,11) = zeros;
                            for pp = 1:size(subNew,1)
                                for p = 1:size(potential_top2,1)
                                    if potential_top2(p,3) == subNew(pp,3)
                                        potential_top2(p,11) = subNew(pp,12);
                                    end
                                end
                            end

                            potential_top2 = potential_top2(potential_top2(:,11)>0,:);
                            potential_top2(potential_top2(:,10) < (modelled_top0(10)*PropConvex),:) = [];
                            potential_top2(potential_top2(:,3) < (modelled_top0(3) + NVert),:) = [];

                            if size(potential_top2,1) > 0
                                potential_top2 = sortrows(potential_top2,10);
                                modelled_top0 = potential_top2(end,1:10);
                            end
                        end

                        modelled_top(count+1,:) = modelled_top0;
                        count = count+1;
                    end
                end
            end
        end
        
        % Remove alongshore outliers:
        % 1. Find outliers:
        modelled_base = sortrows(modelled_base,2);
        modelled_top = sortrows(modelled_top,2);
        
        modelled_top(:,11:15) = zeros;
        modelled_top(:,11) = smoothdata(modelled_top(:,3),'movmedian',SmoothWindow);
        modelled_top(:,12) = modelled_top(:,3) - modelled_top(:,11); % Calculate residuals
        MSE = mean((modelled_top(:,12)).^2);
        modelled_top(:,13) = leverage(modelled_top(:,11)); 
        modelled_top(:,14) = modelled_top(:,12)./(sqrt(MSE*(1-modelled_top(:,13)))); % Calculate standardized residuals
        for n = 1:size(modelled_top,1)
            if abs(modelled_top(n,14)) > 2 % Flag outliers (https://online.stat.psu.edu/stat462/node/172/; accessed on 2021/06/04)
                modelled_top(n,15) = 1; 
            end
        end
        
        fix = modelled_top(modelled_top(:,15)==1,:);
        
        % 2. Delete or replace outliers with more suitable potential cliff tops:
        % (Repeat cliff top detection for the transects with outliers.)
        if size(fix,1) > 0
            good_count = 0;
            for n = min(modelled_base(:,2)):max(modelled_base(:,2))
                for c = 1:size(fix,1)
                    outlier = modelled_top(modelled_top(:,2)==fix(c,2),:);
                    if n == fix(c,2)
                        sub = table(table(:,2)==n,:);

                        % Remove points seawards from the cliff base:
                        for m = 1:size(modelled_base,1)
                            if modelled_base(m,2) == n
                               sub_base = modelled_base(m,:);
                            end
                        end
                        sub = sortrows(sub,3);
                        sub(sub(:,3) < sub_base(3),:) = [];

                        % Draw trendline #2 between cliff base and landward transect end:
                        sub(:,9) = 0;
                        sub(1,9) = sub(1,4);
                        sub(end,9) = sub(end,4);
                        for z = 2:(size(sub,1)-1)
                            sub(z,9) = (sub(z,3)-sub(1,3))*(sub(end,4)-sub(1,4))/(sub(end,3)-sub(1,3))+sub(1,4);
                        end 
                        sub(:,10) = sub(:,4)-sub(:,9);

                        % Find potential cliff top locations:
                        top_count = 0;
                        potential_top2 = zeros(0,10);
                        for m = 1:size(sub,1)
                            if sub(m,5) > TopSea && sub(m,6) < TopLand && sub(m,10) > 0
                                potential_top2(top_count+1,:) = sub(m,:);
                                top_count = top_count+1;
                            end
                        end

                        potential_top2(:,11) = abs(potential_top2(:,3)-fix(c,11));
                        potential_top2 = sortrows(potential_top2,11);
                        potential_top2 = potential_top2(1,:);
                        standardResid = potential_top2(11)/(sqrt(MSE*(1-outlier(:,13))));
                        if abs(standardResid) <= 2
                            good(good_count+1,:) = potential_top2;
                            good_count = good_count+1;
                        end
                    end
                end
            end
            
            if good_count > 0
                outliersDelete = setdiff(fix(:,2), good(:,2));
                modelled_top(ismember(modelled_top(:,2),outliersDelete),:) = [];
                for n = 1:size(modelled_top,1)
                    for c = 1:size(good,1)
                        if modelled_top(n,2) == good(c,2)
                            modelled_top(n,1:10) = good(c,1:10);
                            modelled_top(n,15) = 2;
                        end
                    end
                end
            else
                modelled_top(ismember(modelled_top(:,2),fix(:,2)),:) = [];
            end
        end
                                
        % Save the data:
        savename1 = [fullFileName(1:(end-4)) '_base.txt'];
        dlmwrite(savename1, modelled_base, 'delimiter', '\t', 'precision', 8)
        if size(modelled_top,1) > 0
            savename2 = [fullFileName(1:(end-4)) '_top.txt'];
            dlmwrite(savename2, modelled_top, 'delimiter', '\t', 'precision', 8)       
        end
    end 
end
