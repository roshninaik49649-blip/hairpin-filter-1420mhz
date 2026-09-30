% FILTER SPECIFICATIONS

fc = 1.42e9;
BW = 90e6;
FBW = BW/fc;

% SUBSTRATE

sub = dielectric("FR4");
sub.EpsilonR = 4.2;
sub.Thickness = 0.8e-3;   % using 1.6 mm FR4
sub.LossTangent = 0.02;

% CREATE HAIRPIN FILTER

hairpin = filterHairpin;
hairpin.FilterOrder = 7;
hairpin.Substrate = sub;

% DESIGN FILTER

design(hairpin,fc,'FBW',FBW,'RippleFactor',0.1);

% SHOW GEOMETRY
figure
show(hairpin)


pcb = pcbComponent(hairpin);


% Align ports
pcb = pcbComponent(hairpin);

writer = PCBServices.PCBWayWriter;
writer.Filename = 'Hairpin_Filter_1420MHz';

% Define connectors
C1 = PCBConnectors.SMAEdge_Samtec;
C2 = PCBConnectors.SMAEdge_Samtec;

% Place connectors on board edges
C1.EdgeLocation = 'west';
C1.ExtendBoardProfile = false;

C2.EdgeLocation = 'east';
C2.ExtendBoardProfile = false;

% Generate Gerber
[PW,g] = gerberWrite(pcb,writer,{C1,C2});