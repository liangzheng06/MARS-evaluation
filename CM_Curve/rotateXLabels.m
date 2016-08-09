function hh = rotateXLabels( ax, angle, varargin )
%rotateXLabels: rotate any xticklabels
%
%   hh = rotateXLabels(ax,angle) rotates all XLabels on axes AX by an angle
%   ANGLE (in degrees). Handles to the resulting text objects are returned
%   in HH.
%
%   hh = rotateXLabels(ax,angle,param,value,...) also allows one or more
%   optional parameters to be specified. Possible parameters are:
%     'MaxStringLength'   The maximum length of label to show (default inf)
%
%   Examples:
%   >> bar( hsv(5)+0.05 )
%   >> days = {'Monday','Tuesday','Wednesday','Thursday','Friday'};
%   >> set( gca(), 'XTickLabel', days )
%   >> rotateXLabels( gca(), 45 )
%
%   See also: GCA
%             BAR

%   Copyright 2006-2010 The MathWorks Ltd.
%   $Revision: 52 $
%   $Date: 2010-09-30 11:19:49 +0100 (Thu, 30 Sep 2010) $

error( nargchk( 2, inf, nargin ) );
if ~isnumeric( angle ) || ~isscalar( angle )
    error( 'RotateXLabels:BadAngle', 'Parameter ANGLE must be a scalar angle in degrees' )
end
angle = mod( angle, 360 );

[maxStringLength] = parseInputs( varargin{:} );

% Get the existing label texts and clear them
[vals, labels] = findAndClearExistingLabels( ax, maxStringLength );

% Create the new label texts
h = createNewLabels( ax, vals, labels, angle );

% Reposition the axes itself to leave space for the new labels

%repositionAxes( ax );

% If an X-label is present, move it too
%repositionXLabel( ax );

% Store angle
setappdata( ax, 'RotateXLabelsAngle', angle );

% Only send outputs if requested
if nargout
    hh = h;
end

%-------------------------------------------------------------------------%
    function [maxStringLength] = parseInputs( varargin )
        % Parse optional inputs
        maxStringLength = inf;
        if nargin > 0
            params = varargin(1:2:end);
            values = varargin(2:2:end);
            if numel( params ) ~= numel( values )
                error( 'RotateXLabels:BadSyntax', 'Optional arguments must be specified as parameter-value pairs.' );
            end
            if any( ~cellfun( 'isclass', params, 'char' ) )
                error( 'RotateXLabels:BadSyntax', 'Optional argument names must be specified as strings.' );
            end
            for pp=1:numel( params )
                switch upper( params{pp} )
                    case 'MAXSTRINGLENGTH'
                        maxStringLength = values{pp};
                        
                    otherwise
                        error( 'RotateXLabels:BadParam', 'Optional parameter ''%s'' not recognised.', params{pp} );
                end
            end
        end
    end % parseInputs
%-------------------------------------------------------------------------%
    function [vals,labels] = findAndClearExistingLabels( ax, maxStringLength )
        % Get the current tick positions so that we can place our new labels
        vals = get( ax, 'XTick' );
        
        % Now determine the labels. We look first at for previously rotated labels
        % since if there are some the actual labels will be empty.
        ex = findall( ax, 'Tag', 'RotatedXTickLabel' );
        if isempty( ex )
            % Store the positions and labels
            labels = get( ax, 'XTickLabel' );
            if isempty( labels )
                % No labels!
                return
            else
                if ~iscell(labels)
                    labels = cellstr(labels);
                end
            end
            % Clear existing labels so that xlabel is in the right position
            set( ax, 'XTickLabel', {}, 'XTickMode', 'Manual' );
            setappdata( ax, 'OriginalXTickLabels', labels );
        else
            % Labels have already been rotated, so capture them
            labels = getappdata( ax, 'OriginalXTickLabels' );
            delete(ex);
        end
        % Limit the length, if requested
        if isfinite( maxStringLength )
            for ll=1:numel( labels )
                if length( labels{ll} ) > maxStringLength
                    labels{ll} = labels{ll}(1:maxStringLength);
                end
            end
        end
        
    end % findAndClearExistingLabels

%-------------------------------------------------------------------------%
    function textLabels = createNewLabels( ax, vals, labels, angle )
        % Work out the ticklabel positions
%         ylim = get(ax,'YLim');
%         y = ylim(1);
        zlim = get(ax,'ZLim');
        z = zlim(1);
        
        % We want to work
        % in normalised coords, but switch to normalised after setting
        % position causes positions to be rounded to the nearest pixel.
        % Instead we can do the calculation by hand.
        xlim = get( ax, 'XLim' );
        normVals = (vals-xlim(1))/(xlim(2)-xlim(1));
        y = 0;
        
        % Now create new text objects in similar positions. 
        textLabels = -1*ones( numel( vals ), 1 );
        for ll=1:numel(vals)
            textLabels(ll) = text( ...
                'Units', 'Normalized', ...
                'Position', [normVals(ll), y, z], ...
                'String', labels{ll}, ...
                'Parent', ax, ...
                'Clipping', 'off', ...
                'Rotation', angle, ...
                'Tag', 'RotatedXTickLabel', ...
                'UserData', vals(ll) );
        end
        
        % Now copy font properties into the texts
        updateFont();
        
        % Depending on the angle, we may need to change the alignment. We change
        % alignments within 5 degrees of each 90 degree orientation.
        if 0 <= angle && angle < 5
            set( textLabels, 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Top' );
        elseif 5 <= angle && angle < 85
            set( textLabels, 'HorizontalAlignment', 'Right', 'VerticalAlignment', 'Top' );
        elseif 85 <= angle && angle < 95
            set( textLabels, 'HorizontalAlignment', 'Right', 'VerticalAlignment', 'Middle' );
        elseif 95 <= angle && angle < 175
            set( textLabels, 'HorizontalAlignment', 'Right', 'VerticalAlignment', 'Bottom' );
        elseif 175 <= angle && angle < 185
            set( textLabels, 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Bottom' );
        elseif 185 <= angle && angle < 265
            set( textLabels, 'HorizontalAlignment', 'Left', 'VerticalAlignment', 'Bottom' );
        elseif 265 <= angle && angle < 275
            set( textLabels, 'HorizontalAlignment', 'Left', 'VerticalAlignment', 'Middle' );
        elseif 275 <= angle && angle < 355
            set( textLabels, 'HorizontalAlignment', 'Left', 'VerticalAlignment', 'Top' );
        else % 355-360
            set( textLabels, 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Top' );
        end
    end % createNewLabels

%-------------------------------------------------------------------------%
    function repositionAxes( ax )
        % Reposition the axes so that there's room for the labels
        % Note that we only do this if the OuterPosition is the thing being
        % controlled
        if ~strcmpi( get( ax, 'ActivePositionProperty' ), 'OuterPosition' )
            return;
        end
        
        % Work out the maximum height required for the labels
        textLabels = findall( ax, 'Tag', 'RotatedXTickLabel' );
        maxHeight = 0;
        for ii=1:numel(vals)
            ext = get( textLabels(ii), 'Extent' );
            if ext(4) > maxHeight
                maxHeight = ext(4);
            end
        end
        
        % Remove listeners while we mess around with things, otherwise we'll
        % trigger redraws recursively
        removeListeners( ax );
        
        % Change to normalized units for the position calculation
        oldUnits = get( ax, 'Units' );
        set( ax, 'Units', 'Normalized' );
        
        % Not sure why, but the extent seems to be proportional to the height of the axes.
        % Correct that now.
        set( ax, 'ActivePositionProperty', 'Position' );
        pos = get( ax, 'Position' );
        axesHeight = pos(4);
        % Make sure we don't adjust away the axes entirely!
        heightAdjust = min( (axesHeight*0.9), maxHeight*axesHeight );
        
        % Move the axes
        if isappdata( ax, 'OriginalAxesPosition' )
            pos = getappdata( ax, 'OriginalAxesPosition' );
        else
            pos = get(ax,'Position');
            setappdata( ax, 'OriginalAxesPosition', pos );
        end
        setappdata( ax, 'PreviousYLim', get( ax, 'YLim' ) );
        set( ax, 'Position', pos+[0 heightAdjust 0 -heightAdjust] )
        set( ax, 'Units', oldUnits );
        set( ax, 'ActivePositionProperty', 'OuterPosition' );
        
        % Make sure we find out if axes properties are changed
        addListeners( ax );
        
    end % repositionAxes

%-------------------------------------------------------------------------%
    function repositionXLabel( ax )
        % Try to work out where to put the xlabel
        
        removeListeners( ax );
        textLabels = findall( ax, 'Tag', 'RotatedXTickLabel' );
        maxHeight = 0;
        for ll=1:numel(vals)
            ext = get( textLabels(ll), 'Extent' );
            if ext(4) > maxHeight
                maxHeight = ext(4);
            end
        end
        
        % Use the new max extent to move the xlabel
        xlab = get(ax,'XLabel');
        set( xlab, 'Units', 'Normalized', 'Position', [0.5 -maxHeight 0] );
        addListeners( ax );
    end % repositionXLabel

%-------------------------------------------------------------------------%
    function updateFont()
        % Update the rotated text fonts when the axes font changes
        properties = {
            'FontName'
            'FontSize'
            'FontAngle'
            'FontWeight'
            'FontUnits'
            };
        propertyValues = get( ax, properties );
        textLabels = findall( ax, 'Tag', 'RotatedXTickLabel' );
        set( textLabels, properties, propertyValues );
    end % updateFont

%-------------------------------------------------------------------------%
    function onAxesFontChanged()
        updateFont();
        repositionAxes( ax );
        repositionXLabel( ax );
    end % onAxesFontChanged

%-------------------------------------------------------------------------%
    function onAxesPositionChanged()
        % We need to accept the new position, so remove the appdata before
        % redrawing
        if isappdata( ax, 'OriginalAxesPosition' )
            rmappdata( ax, 'OriginalAxesPosition' );
        end
        if isappdata( ax, 'OriginalXLabelPosition' )
            rmappdata( ax, 'OriginalXLabelPosition' );
        end
        repositionAxes( ax );
        repositionXLabel( ax );
    end % onAxesPositionChanged

%-------------------------------------------------------------------------%
    function onAxesLimitsChanged()
        % The limits have moved, so make sure the labels are still ok
        textLabels = findall( ax, 'Tag', 'RotatedXTickLabel' );
        xlim = get( ax, 'XLim' );
        for tt=1:numel( textLabels )
            xval = get( textLabels(tt), 'UserData' );
            pos(1) = (xval-xlim(1)) / (xlim(2)-xlim(1));
            pos(2) = 0;
            % If the tick is off the edge, make it invisible
            if xval<xlim(1) || xval>xlim(2)
                set( textLabels(tt), 'Visible', 'off', 'Position', pos )
            elseif ~strcmpi( get( textLabels(tt), 'Visible' ), 'on' )
                set( textLabels(tt), 'Visible', 'on', 'Position', pos )
            else
                % Just set the position
                set( textLabels(tt), 'Position', pos );
            end
        end
        
        repositionXLabel( ax );
        
%         xlab = get(ax,'XLabel');
%         if ~strcmpi( get( xlab, 'Units' ), 'Data' )
%             set( xlab, 'Units', 'data' );
%         end
%         pos = get( xlab, 'Position' );
%         orig_yrange = diff( orig_ylim );
%         new_yrange = diff( ylim );
%         offset = (pos(2)-orig_ylim(1)) / orig_yrange;
%         pos(2) = offset * new_yrange + ylim(1);
%         pos(1) = mean( xlim );
%         set( xlab, 'Position', pos );
%         setappdata( ax, 'PreviousYLim', ylim );
    end % onAxesPositionChanged

%-------------------------------------------------------------------------%
    function addListeners( ax )
        % Create listeners. We store the array of listeners in the axes to make
        % sure that they have the same life-span as the axes they are listening to.
        axh = handle( ax );
        listeners = [
            handle.listener( axh, findprop( axh, 'FontName' ), 'PropertyPostSet', @onAxesFontChanged )
            handle.listener( axh, findprop( axh, 'FontSize' ), 'PropertyPostSet', @onAxesFontChanged )
            handle.listener( axh, findprop( axh, 'FontWeight' ), 'PropertyPostSet', @onAxesFontChanged )
            handle.listener( axh, findprop( axh, 'FontAngle' ), 'PropertyPostSet', @onAxesFontChanged )
            handle.listener( axh, findprop( axh, 'FontUnits' ), 'PropertyPostSet', @onAxesFontChanged )
            handle.listener( axh, findprop( axh, 'OuterPosition' ), 'PropertyPostSet', @onAxesPositionChanged )
            handle.listener( axh, findprop( axh, 'XLim' ), 'PropertyPostSet', @onAxesLimitsChanged )
            handle.listener( axh, findprop( axh, 'YLim' ), 'PropertyPostSet', @onAxesLimitsChanged )
            ];
        setappdata( ax, 'RotateXLabelsListeners', listeners );
    end % addListeners

%-------------------------------------------------------------------------%
    function removeListeners( ax )
        % Rempove any property listeners whilst we are fiddling with the axes
        if isappdata( ax, 'RotateXLabelsListeners' )
            delete( getappdata( ax, 'RotateXLabelsListeners' ) );
            rmappdata( ax, 'RotateXLabelsListeners' );
        end
    end % removeListeners



end % EOF