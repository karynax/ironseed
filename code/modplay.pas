unit modplay;
(********************************************************************
    This file is part of Ironseed.

    Ironseed is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Ironseed is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Ironseed.  If not, see <http://www.gnu.org/licenses/>.
********************************************************************)

{$O+}

{***************************
   High Level Mod Playing Routines

   Channel 7
   Destiny: Virtual


   Copyright 1994

***************************}

interface

{$I DSMI.INC};

type
   configfile = 
   record     
      tslice,rate,soundcard,irq,dma,port,stereo,music : word;
   end;	      
var
   cf		    : configfile;
   playing,moderror : boolean;
   {checkerror	    : boolean;}
   module	    : pmodule;
   sc		    : tsoundcard;

procedure initializemod;
procedure stopmod;
procedure haltmod;
procedure playmod(looping: boolean;s: string);
procedure setmodvolume;
procedure setmodvolumeto(vol : Integer);
procedure soundeffect(s: string; rate: integer);
procedure pausemod;
procedure continuemod;
function getpattern: integer;
function getrow: integer;
function getstatus: boolean;

implementation

uses crt, emhm, data, getcpu, utils, strings;

var
 oldsi: tsampleinfo;

function loadconfigfile : boolean;
var
   f : file of configfile;
begin
   loadconfigfile := true;
   assign(f, 'sound.cfg');
   if ioresult<>0 then begin
      loadconfigfile := false;
      exit;
   end;
   reset(f);
   if ioresult<>0 then begin
      loadconfigfile := false;
      exit;
   end;
   read(f, cf);
   if ioresult<>0 then begin
      loadconfigfile := false;
   end;
   close(f);
end;


procedure initializemod;
var options,j,card,err,irq,dma,port: integer;
    str1: string[20];
    valstr: string[10];
    override: boolean;
begin
   options:=MCP_QUALITY;
   if getcputype and 4>0 then options:=options or MCP_486;
   fillchar(sc,sizeof(sc),0);
   card:=0;
   irq:=7;
   dma:=1;
   port:=544;
   override:=false;
   sc.minrate:=8000;
   sc.maxrate:=44100;
   if loadconfigfile then
   begin
      if cf.soundcard <> 0 then
      begin
	 override := true;
	 case cf.soundcard of
	   9 : card := 0;
	   1 : card := ID_SB;
	   2 : card := ID_SBPRO;
	   3 : card := ID_SB16;
	   5 : card := ID_PAS;
	   6 : card := ID_PASPLUS;
	   7 : card := ID_PAS16;
	   {? : card := ID_DAC;}
	   4 : card := ID_ARIA;
	   {? : card := ID_WSS;}
	   8 : card := ID_GUS;
	 else begin
	    
	 end;
	 end; { case }
	 port := cf.port;
	 irq := cf.irq;
	 dma := cf.dma;
	 sc.maxrate := cf.rate;
	 sc.stereo := cf.stereo <> 0;
      end;
   end;
   for j:=2 to 10 do
      if (paramstr(j)<>'') then
      begin
	 str1:=paramstr(j);
	 if (str1[1]='/') and (upcase(str1[2])='S') then
	 begin
	    valstr:=copy(str1,3,10);
	    val(valstr,card,err);
	    if (err<>0) then errorhandler('Invalid Parameter: '+paramstr(j),6);
	    override:=true;
	 end;
	 if (str1[1]='/') and (upcase(str1[2])='P') then
	 begin
	    valstr:=copy(str1,3,10);
	    val(valstr,port,err);
	    if (err<>0) then errorhandler('Invalid Parameter: '+paramstr(j),6);
	    override:=true;
	 end;
	 if (str1[1]='/') and (upcase(str1[2])='D') then
	 begin
	    valstr:=copy(str1,3,10);
	    val(valstr,dma,err);
	    if (err<>0) then errorhandler('Invalid Parameter: '+paramstr(j),6);
	    override:=true;
	 end;
	 if (str1[1]='/') and (upcase(str1[2])='I') then
	 begin
	    valstr:=copy(str1,3,10);
	    val(valstr,irq,err);
	    if (err<>0) then errorhandler('Invalid Parameter: '+paramstr(j),6);
	    override:=true;
	 end;
      end;
   if (override) then
   begin
      sc.dmairq:=irq;
      sc.ioport:=port;
      sc.dmachannel:=dma;
      sc.id:=card;
   end;
   if (emsinit(800,800)<>0) or (initdsmi(44100,2048,options,@sc,override)<>0) then
   begin
      moderror:=true;
      exit;
   end;
end;

procedure stopmod;
var i: integer;
begin
 if (moderror) or (not playing) then exit;
 if sc.id<>ID_GUS then
  for i:=ship.options[9] downto 0 do
   begin
    mcpsetmastervolume(i);
    delay(10);
   end
 else
  for i:=ship.options[9] downto 0 do
   begin
    gussetmastervolume(i);
    delay(10);
   end;
 playing:=false;
 if sc.id<>ID_GUS then mcpclearbuffer;
 ampstopmodule;
 ampfreemodule(module);
end;

procedure haltmod;
var i: integer;
begin
 if (moderror) or (not playing) then exit;
 playing:=false;
 if sc.id<>ID_GUS then mcpclearbuffer;
 ampstopmodule;
 ampfreemodule(module);
end;

procedure playmod(looping: boolean;s: string);
var j: integer;
    voltable: array[0..31] of integer;
    error: integer;
    f: file;
begin
 if (moderror) or (ship.options[3]=0) then exit;
 assign(f,s);
 reset(f);
 if ioresult<>0 then
  begin
   close(f);
   {checkerror := true;}
   j:=ioresult;
   j:=ioresult;
   exit;
  end;
 close(f);
 {checkerror := false;}
 if playing then stopmod;
 module:=amploadmod(s,LM_IML);
 if module=nil then
  begin
   playing:=false;
   exit;
  end;
 if sc.id<>ID_GUS then mcpStartVoice else gusStartVoice;
 for j:=0 to 31 do voltable[j]:=j*2+1;
 if sc.id<>ID_GUS then
  begin
   cdiSetupChannels(0,module^.channelCount+4,@voltable);
   for j:=0 to module^.channelcount-1 do cdisetpan(j,40);
   cdisetpan(module^.channelcount,-100);
   cdisetpan(module^.channelcount+1,100);
   cdisetpan(module^.channelcount+2,-100);
   cdisetpan(module^.channelcount+3,100);
  end
 else
  begin
   cdiSetupChannels(0,module^.channelCount+1,@voltable);
   for j:=0 to module^.channelcount-1 do cdisetpan(j,40);
   cdisetpan(module^.channelcount,0);
  end;
 if sc.id<>ID_GUS then mcpsetmastervolume(ship.options[9])
  else gussetmastervolume(ship.options[9]);
 if looping then error:=ampplaymodule(module,PM_Loop)
  else error:=ampplaymodule(module,0);
 if error<>0 then errorhandler('Error Playing Module.',7);
 playing:=true;
end;

procedure setmodvolume;
begin
 if (moderror) or (not playing) then exit;
 if sc.id<>ID_GUS then mcpsetmastervolume(ship.options[9])
  else gussetmastervolume(ship.options[9]);
end;

procedure setmodvolumeto(vol : Integer);
begin
 if (moderror) or (not playing) then exit;
 if sc.id<>ID_GUS then mcpsetmastervolume(vol)
  else gussetmastervolume(vol);
end;

procedure soundeffect(s: string; rate: integer);
var f: file;
    size,j: integer;
    si: tsampleinfo;
begin
 if (moderror) or (ship.options[3]=0) or (sc.id=ID_GUS) then exit;
 assign(f,'sound\'+s);
 reset(f,1);
 if ioresult<>0 then
  begin
   close(f);
   j:=ioresult;
   j:=ioresult;
   exit;
  end;
 size:=filesize(f);
 if memavail<size*2 then exit;
 getmem(si.sample,size);
 blockread(f,si.sample^,size);
 if ioresult<>0 then errorhandler(s,6);
 close(f);
 if rate=0 then rate:=11900;
 with si do
  begin
   length:=size;
   loopstart:=0;
   loopend:=0;
   mode:=0;
   sampleid:=0;
  end;
 mcpconvertsample(si.sample,size);
 for j:=0 to 3 do if mcpsetsample(module^.channelcount+j,@si)<>0 then errorhandler(s+', Setting sample.',7);
 for j:=0 to 3 do if mcpplaysample(module^.channelcount+j,rate+j*5,64)<>0 then errorhandler(s+', Playing.',7);
 delay(40);
 freemem(si.sample,size);
end;

procedure pausemod;
begin
 if (moderror) or (not playing) or (ship.options[3]=0) then exit;
 if sc.id<>ID_GUS then mcpPauseVoice else gusPauseAll;
end;

procedure continuemod;
begin
 if (moderror) or (not playing) or (ship.options[3]=0) then exit;
 if sc.id<>ID_GUS then mcpResumeVoice else gusResumeAll;
end;

function getpattern: integer;
begin
 if (moderror) or (not playing) or (ship.options[3]=0) then getpattern:=0
  else getpattern:=ampgetpattern;
end;

function getrow: integer;
begin
 if (moderror) or (not playing) or (ship.options[3]=0) then getrow:=0
  else getrow:=ampgetrow;
end;

function getstatus: boolean;
begin
 if (moderror) or (not playing) or (ship.options[3]=0) then getstatus:=false
  else
   begin
    if ampgetmodulestatus=MD_PLAYING then getstatus:=true
     else getstatus:=false;
   end;
end;

begin
 oldsi.length:=0;
 playing:=false;
 moderror:=false;
end.
