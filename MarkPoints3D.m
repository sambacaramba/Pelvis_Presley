function markedPoints = MarkPoints3D(vol, savepath, filename)

global markedPoints;
% Initialize an empty array to store marked points
markedPoints = NaN(11, 3);  % Pre-allocate for 13 points

xyz = size(vol);






% Compute the isosurface
[x, y, z] = meshgrid(1:xyz(2), 1:xyz(1), 1:xyz(3));
[F, V] = isosurface(x, y, z, vol, 0.5);

% Visualize the isosurface
fig = figure('Name', 'Isosurface Marking Tool', 'Position', [100, 100, 1200, 800]);

% Plot the isosurface
ax = axes('Position', [0.25, 0.1, 0.7, 0.8]);  % Positioning the plot to the right side of the figure
isosurfacePlot = trisurf(F, V(:,1), V(:,2), V(:,3), 'FaceColor', 'cyan', 'EdgeColor', 'none');
axis equal;
xlabel('X-axis');
ylabel('Y-axis');
zlabel('Z-axis');
title('Isosurface Visualization');
shading interp
lighting gouraud;
camlight;
rotate3d on;  % Enable rotation for easier interaction

% Hold on to add points interactively
hold on;

% Create buttons for selecting points to mark
buttonHandles = gobjects(11, 1);
for i = 1:11
    buttonHandles(i) = uicontrol('Style', 'pushbutton', 'String', ['Mark Point ', num2str(i)], ...
        'Position', [20, 550 - 35 * i, 100, 30], 'Callback', @(src, event) markPoint(i));
end

% Add an exit & save button
exitButton = uicontrol('Style', 'pushbutton', 'String', 'Exit & Save', ...
    'Position', [20, 50, 100, 30], 'Callback', @(src, event) exitAndSave());

% Pause the script until the figure is closed (wait for user interaction)
uiwait(fig);


% Function to enter marking mode for a specific point
function markPoint(pointIndex)
    % Disable rotation mode
    rotate3d off;
    disp(['Marking Point ', num2str(pointIndex), '. Click on the isosurface.']);
    
    % Clear any existing data cursors to avoid auto-marking
    dcm = datacursormode(gcf);
    dcm.removeAllDataCursors();
    datacursormode on;
    
    % Set a callback for clicking on the plot
    set(dcm, 'UpdateFcn', @(src, event) recordPointCallback(event, pointIndex));
end

% Function to record the clicked point
function txt = recordPointCallback(eventObj, pointIndex)
    % Get the clicked point's position
    point = get(eventObj, 'Position');
    
    % Store the marked point and add to plot
    markedPoints = evalin('base', 'markedPoints');
    markedPoints(pointIndex, :) = point;
    assignin('base', 'markedPoints', markedPoints);  % Store updated points in base workspace
    
    % Plot the marked point with a red dot
    plot3(point(1), point(2), point(3), 'r.', 'MarkerSize', 15);
    
    % Display text for the cursor (optional)
    txt = {['X: ', num2str(point(1))], ...
           ['Y: ', num2str(point(2))], ...
           ['Z: ', num2str(point(3))]};
    
    % Disable data cursor mode and re-enable rotation
    datacursormode off;
    rotate3d on;
    disp(['Point ', num2str(pointIndex), ' marked at [', num2str(point), '].']);
end

% Function to exit marking mode and save marked points
function exitAndSave()
   
    % Save the marked points to the workspace or a file
    assignin('base', 'markedPoints', markedPoints);  % Assign to base workspace
%     save(fullfile(savepath, 'markedPoints.mat'), 'markedPoints');  % Save to a .mat file
    
%plot 3d lines to figure to their correct places showing the distances



    % Define the pairs of indices for each line to be drawn
pairs = [
    1, 5;  % 1 to 7, INL hip bone length
    3, 4;  % 5 to 6, SPL symphysis length
    3, 6;  % 5 to 8, APL
    2, 3;  % 4 to 5
    4, 5;  % 6 to 7, IPL
    5, 6;  % 8 to 7, AIL
    5, 9; % 11 to 7, ISW
    7, 8; % 9 to 10, obturator foramen length
    5, 11  % 12 to 10, FTF, foramen to foramen
    8, 10; % 13 to 7, TTT, ischial tuberosity to ischial tuberosity
];

% Loop through the pairs and plot the lines
isosurfacePlot.FaceAlpha = 0.7;

for jjj = 1: size(pairs,1)
    idx1 = pairs(jjj, 1);
    idx2 = pairs(jjj, 2);
    
    % Extract the coordinates of the points
    point1 = markedPoints(idx1, :);
    point2 = markedPoints(idx2, :);
    
    % Plot the line between the points
    plot3([point1(1), point2(1)], [point1(2), point2(2)], [point1(3), point2(3)], 'k-', 'LineWidth', 2);
end

    % Save the visualization as an image using exportgraphics
    exportgraphics(ax, fullfile(savepath, filename));
    disp(['Visualization image saved to: ', fullfile(savepath, filename)]);
    disp('Marking completed. Points saved.');
    
    % Close the figure
     uiresume(gcf);
    close(gcf);
end

end
