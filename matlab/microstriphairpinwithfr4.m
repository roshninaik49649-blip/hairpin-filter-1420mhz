% FILTER SPECIFICATIONS

fc = 1.42e9;
BW = 90e6;
FBW = BW/fc;

% SUBSTRATE

sub = dielectric("FR4");
sub.EpsilonR = 4.2;
sub.Thickness = 0.8e-3;   % using 1.6 mm FR4
sub.LossTangent = 0.02;


% Use the calculated decimal value here
design(hp, fc, 'FBW', fbw_value);
hp.CoupledLineWidth = 1.5e-3; 
hp.CoupledLineLength = 0.026;
hp.CoupledLineSpacing = [0.0005, 0.0008]
hp.PortLineWidth = 1.5e-3;; 
hp.PortLineLength = 5e-3;

% DESIGN FILTER
bw = 90e6;
fc = 1.42e9;
fbw_value = bw / fc; 
design(hairpin, fc, 'FBW', fbw_value, 'RippleFactor', 0.1);

% SHOW GEOMETRY (required before gerber export)

figure
show(hairpin)

% CONVERT TO PCB COMPONENT

pcb = pcbComponent(hairpin);
p = pcbStack;
p.BoardThickness = 0.8e-3;
p.Layers = {hairpin, dielectric('FR4'), antenna.Rectangle('Length', 0.12, 'Width', 0.08)};
p.BoardShape = antenna.Rectangle('Length', 0.12, 'Width', 0.08);

% DEFINE PCB WRITER

writer = PCBServices.MayhewWriter;
writer.Filename = 'Microstrip_Hairpin_Filter_1420MHzFinal';

% OPTIONAL CONNECTOR

connector = PCBConnectors.SMAEdge_Samtec;

%  Setup Connectors 
W = PCBServices.MayhewWriter;
C1 = PCBConnectors.SMAEdge_Samtec; C1.EdgeLocation = 'west';
C2 = PCBConnectors.SMAEdge_Samtec; C2.EdgeLocation = 'east';

%  Export 
AM = PCBWriter(p, W, {C1, C2});
gerberWrite(AM);

%  Feed Locations
p.FeedLocations = [-0.06, 0, 1, 3;  % Port 1 at the left edge
                    0.06, 0, 1, 3]; % Port 2 at the right edge
p.FeedDiameter = 1.5e-3/2; 

C1 = PCBConnectors.SMAEdge_Samtec;
C1.EdgeLocation = 'west';
C2 = PCBConnectors.SMAEdge_Samtec;
C2.EdgeLocation = 'east';
% 4. Export
W = PCBServices.MayhewWriter;
AM = PCBWriter(p, W, {C1, C2});
gerberWrite(AM);

layout(hairpin)

% 1. Convert the filter object into a raw metal shape
hairpinShape = extractStructure(hairpin);

% 2. Define the Board Shape (Ground Plane)
gnd = antenna.Rectangle('Length', 0.12, 'Width', 0.08);

% 3. Assign the layers correctly
% Top Layer: The Metal Shape
% Middle Layer: The Dielectric
% Bottom Layer: The Ground Shape
p.Layers = {hairpinShape, dielectric('FR4'), gnd};

% 4. Set the board outline to match the ground
p.BoardShape = gnd;