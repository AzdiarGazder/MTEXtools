function jeolOI2Mtex_step1

%% USER NOTES:
% It is implicitly assumed that:
% 1.1. The user will read these notes throughly and in detail.
%
% 1.2. The user knows the plane and macroscopic sample directions from
% where the EBSD map was collected using a combination of a JEOL
% scanning electron microscope (SEM) and Oxford Instruments (OI) EBSD(+EDS)
% system.
%
% 1.3. The user does not know how to correctly represent EBSD map data in
% Mtex.
%
% 1.4 When running the Step 1 script, how the map is spatially displayed 
% in Mtex may differ from how it is spatially displayed in OI Channel-5 or
% Aztec Crystal. For example, the map may be rotated clockwise, 
% anti-clockwise, flipped, or any combination of such motions. These issues
% are to be ignored in Step 1 and corrected in Step 2.



%% Before running this script, please do the following:
% 2.1. Go to OI Channel-5 or Aztec Crystal.
%
% 2.2. Load the (cpr/crc, ctf, oip, or h5oina) EBSD map data you wish to
% load in this script and work on in MTex.
%
% 2.3. Ensure the virtual chamber correctly represents the plane from where
% the EBSD map data was collected.
%
% 2.4. Using the EBSD map data, display an IPF map (here, choose one direction
% that best represents the primary deformation direction of your sample
% (IPFx, or IPFy or IPFz).
%
% 2.5. Using the EBSD map data, display at least 3 pole figures. Here
% choose the PF display convention, and a representative step size for the 
% contour levels in the pole figures that best describes the texture.
%
% 2.6. Using the EBSD map data, display at least 3 ODF sections. Here
% choose a representative step size for the contour levels in the ODF that
% best describes the texture.
%
% 2.7. Save the cpr/crc or h5oina file for import into this script or Mtex.
% Alternatively, export the aligned EBSD map data as a ctf file for import
% into this script or Mtex.



%% OBJECTIVE:
% The objective of this script is to systematically rotate the ebsd map 
% orientation data in phi1, Phi and phi2. The user must select a 
% combination of phi1, Phi and phi2 that exactly matches the 
% crystallographic texture displayed in OI Channel-5 or Aztec Crystal. 
%
% Press any key to choose the next combination of phi1, Phi and phi2.
% Press the Esc key to exit the script.
%
% Here the term "matching crystallographic texture" specifically refers to:
%
% 3.1. an IPF map of the user's choosing (IPFx, IPFy, or IPFz) showing
% subgrains/grains in the same colors in Mtex as that displayed in
% OI Channel-5 or Aztec Crystal.
%
% AND
%
% 3.2. three pole figures of the user's choosing showing blobs in the same
% position in Mtex as that displayed in Channel-5 or Aztec Crystal.
%
% AND
%
% 3.3. three ODF sections of the user's choosing showing blobs in the same
% position in Mtex as that displayed in Channel-5 or Aztec Crystal.



%% Initialise Mtex
close all; clc; clear all; clear hidden;
startup_mtex



%% Define the Mtex plotting convention
% 4.1. The Mtex plotting convention affects the plotting of both, maps
% (specifically, inverse pole figure maps) AND crystallogrpahic texture
% representations (pole figures & orientation distribution fucntions).
%
% 4.2. Keeping point (4.1) in mind, the selected Mtex plotting convention
% is usually the same as that used to display the texture.
%
% In the demonstration example shown here, the EBSD map data was obtained 
% from a 60% cold-rolled sample:
% - The rolling direction (RD) is along the map horizontal.
% - The normal direction (ND) is along the map vertical.
% - The transverse direction (TD) is out-of-plane of the map.
%
% The accepted convention to describe crystallographic texture for rolling
% is as follows:
% - The rolling direction (RD) is along the pole figure south-to-north.
% - The transverse direction (TD) is along the pole figure west-to-east.
% - The normal direction (ND) is along is along the pole figure out-of-
% plane to into-plane.
%
% Based on points (4.1) and (4.2), the MTex plotting convention is defined
% as:
setMTEXpref('xAxisDirection','north');
setMTEXpref('zAxisDirection','intoPlane');



%% Define the crystal systems of the phases in the ebsd map
CS = {...
    'notIndexed',...
    crystalSymmetry('SpaceId',225,[3.7 3.7 3.7],'mineral','Iron fcc','color',[0 0 1]),...
    crystalSymmetry('SpaceId',229,[2.9 2.9 2.9],'mineral','Iron bcc (old)','color',[1 0 0]),...
    crystalSymmetry('SpaceId',191,[2.5 2.5 4.1],'X||a*', 'Y||b', 'Z||c*','mineral','Epsilon_Martensite','color',[1 1 0])};



%% Import the EBSD map data
% directory path
pname = 'C:\Users\azdiar\Documents\MATLAB\GitHub\mtexTools\jeolOI2Mtex\';
% file name
% fname = 'MEA_60CR_1C.cpr';
fname = 'MEA_60CR_1C.ctf';
% create an EBSD variable containing the map data
ebsd = EBSD.load([pname fname],CS,'interface','ctf',...
    'convertSpatial2EulerReferenceFrame');
% use only indexed map data
ebsd = ebsd('indexed');
% in case of multi-phase maps, select the dominant phase to work with
ebsd = ebsd('Iron fcc');



%% Define the preferences for plotting crystallographic texture
% define the pole figures to display
hpf = {Miller(1,1,1,ebsd.CS),...
    Miller(2,0,0,ebsd.CS),...
    Miller(2,2,0,ebsd.CS)};
% define the step size for the contour levels in the pole figures
pfContourStep = 1;
% define the colomap in the pole figures
pfColormap = flipud(colormap(gray));

% define the ODF sections to display
odfSections = [0 45 65]*degree;
% define the step size for the contour levels in the ODF
odfContourStep = 5;
% define the colomap in the ODF
odfColormap = flipud(colormap(gray));








%% DO NOT MODIFY BELOW THIS LINE
disp('--------')
disp('Press any key to choose the next combination of phi1, Phi and phi2.')
disp('Press the Esc key to exit the script.')

phi1 = -360:90:360;
Phi = -360:90:360;
phi2 = -360:90:360;

for ii = 1:length(phi1)
    for jj = 1:length(Phi)
        for kk = 1:length(phi2)

            disp('--------')
            idx = nestedLoopCounter([ii jj kk],1:length(phi1),1:length(Phi),1:length(phi2));
            disp(['Counter = ', num2str(idx), '/',num2str(length(phi1)*length(Phi)*length(phi2)), ': phi1 = ',num2str(phi1(ii)), 'º, PHI = ',num2str(Phi(jj)), 'º, phi2 = ',num2str(phi2(kk)),'º']);
            disp('--------')

            % From Step 1: input one combination of phi1, Phi and phi2
            % such that the ebsd map orientation data displayed in Mtex has
            % the same colors and format as that shown in OI Channel-5 or 
            % Aztec Crystal
            ebsdRot = rotate(ebsd,rotation('Euler', phi1(ii)*degree, Phi(jj)*degree, phi2(kk)*degree),'keepXY');
            

            %% plot the ebsd orientation data to check if it matches Channel-5 or Aztec
            ipfKey = ipfColorKey(ebsdRot);
            % set the referece direction to X
            ipfKey.inversePoleFigureDirection = vector3d.X;
            % compute the colors
            colors = ipfKey.orientation2color(ebsdRot.orientations);
            % plot the ebsd data together with the colors
            figH = figure(1);
            plot(ebsdRot,colors)

            %--- Calculate the orientation distribution function and define the specimen symmetry of the parent
            psi = calcKernel(ebsdRot.orientations,'method','ruleOfThumb');
            odf = calcDensity(ebsdRot.orientations,'de la Vallee Poussin',...
                'kernel',psi);
            %--- Re-define the specimen symmetry
            odf.SS = specimenSymmetry('orthorhombic');
            %--- Calculate the value and orientation of the maximum f(g) in the ODF
            [maxodf_value,~] = max(odf);
            %---

            %--- Calculate the pole figures from the orientation distribution function
            pf = calcPoleFigure(odf,hpf,regularS2Grid('resolution',2*psi.halfwidth),'antipodal');
            %--- Calculate the value of the maximum f(g) in the PF
            maxpf_value = max(max(pf));
            %---

            %--- Plot the pole figures
            figH = figure(2);
            odf.SS = specimenSymmetry('triclinic');
            plotPDF(odf,...
                hpf,...
                'points','all',...
                'equal','antipodal',...
                'contourf',1:pfContourStep:ceil(maxpf_value));
            hold all;
            colormap(pfColormap);
            % flipud(pfColormap); % option to flip the colorbar
            caxis([1 ceil(maxpf_value)]);
            colorbar('location','eastOutSide','LineWidth',1.25,'TickLength', 0.01,...
                'YTick', [1:pfContourStep:ceil(maxpf_value)],...
                'YTickLabel',num2str([1:pfContourStep:ceil(maxpf_value)]'), 'YLim', [1 ceil(maxpf_value)],...
                'TickLabelInterpreter','latex','FontName','Helvetica','FontSize',14,'FontWeight','bold');
            set(figH,'Name','Pole figure(s)','NumberTitle','on');
            hold off;
            drawnow;
            odf.SS = specimenSymmetry('orthorhombic');
            %---

            %--- Plot the orientation distribution function
            figH3 = figure(3);
            plotSection(odf,...
                'phi2',odfSections,...
                'points','all','equal',...
                'contourf',1:odfContourStep:ceil(maxodf_value));
            hold all;
            colormap(odfColormap);
            % flipud(odfColormap); % option to flip the colorbar
            caxis([1 ceil(maxodf_value)]);
            colorbar('location','eastOutSide','LineWidth',1.25,'TickLength', 0.01,...
                'YTick', (1:odfContourStep:ceil(maxodf_value)),...
                'YTickLabel',num2str((1:odfContourStep:ceil(maxodf_value))'), 'YLim', [1 ceil(maxodf_value)],...
                'TickLabelInterpreter','latex','FontName','Helvetica','FontSize',14,'FontWeight','bold');
            set(figH3,'Name','Orientation distribution function (ODF)','NumberTitle','on');
            odf.SS = specimenSymmetry('orthorhombic');
            hold off;
            drawnow;
            %---

            [keyCode,~] = getKey(1); % wait for user input
            if keyCode == 27 % ascii code if the escape key is presssed
                return % exit the loop
            else % continue the loop
                clear ebsdRot
                close all
            end
        end
    end
end
end


