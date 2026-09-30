% 1. Design the Filter Object
fc = 1.42e9;
bw = 90e6;
fbw_value = bw / fc;

hp = filterHairpin;
hp.FilterOrder = 7;
hp.Substrate = dielectric('EpsilonR', 4.4, 'Thickness', 0.8e-3);

% Run initial design to populate dimensions
design(hp, fc, 'FBW', fbw_value, 'RippleFactor', 0.1);

% Apply your custom requirements using the verified property names
hp.CoupledLineLength = 0.0265;   % Frequency adjustment
hp.CoupledLineWidth  = 0.0015;   % 50-ohm width for 0.8mm board
hp.CoupledLineSpacing = [0.0005, 0.0008]; % Symmetric gaps
hp.PortLineWidth = 1.5e-3;       % Ensure port matches trace width
hp.PortLineLength = 5e-3;

% 2. Build the PCB Stack 
hairpinMetal = shapes(hp);

% Define the board dimensions
boardLen = 0.12; 
boardWid = 0.08;
gnd = antenna.Rectangle('Length', boardLen, 'Width', boardWid);

p = pcbStack;
p.Name = 'Hairpin_Filter_Final';
p.BoardThickness = 0.8e-3;
p.BoardShape = gnd;

p.Layers = {hairpinMetal{1}, dielectric('EpsilonR', 4.4, 'Thickness', 0.8e-3), gnd}

% Position the Feed Points at the West and East edges, centered at Y=0
% Format: [X, Y, StartLayer, StopLayer]
p.FeedLocations = [-boardLen/2, 0, 1, 3;  % Input
                    boardLen/2, 0, 1, 3]; % Output
p.FeedDiameter = 1.5e-3/2;

% 3. Setup Connectors and Export
W = PCBServices.MayhewWriter;

% Define Samtec SMA Edge Mounts for both sides
C1 = PCBConnectors.SMAEdge_Samtec; C1.EdgeLocation = 'west';
C2 = PCBConnectors.SMAEdge_Samtec; C2.EdgeLocation = 'east';

% Create the writer and generate files
AM = PCBWriter(p, W, {C1, C2});
gerberWrite(AM);

% Visualize the result
figure;
show(p);
