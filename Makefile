
export WINEPREFIX=/home/xen/.wine-ironseed/
WINE=wine

FIXNAMES=python code/fixnames.py

DMPSRC=$(shell find dmp -name "*.pas")
MAINSRC=$(shell find code -name "*.pas") $(DMPSRC)
CREWGENSRC=code/crewgen.pas code/data.pas code/gmouse.pas code/saveload.pas code/display.pas code/utils.pas code/modplay.pas $(DMPSRC)
INTROSRC=code/intro.pas code/version.pas code/gmouse.pas code/modplay.pas $(DMPSRC)
ISSRC=code/is.pas

TPC=$(WINE) f:/bp/bin/tpc.exe /Tf:\\bp\\bin
TPCFLAGS=/B /Q /M /DUSE_EMS /L /GD /\$$N+ /\$$G+ /\$$S- /\$$I-
TPCTOOLFLAGS=/B /Q /M /DUSE_EMS /L /GD /\$$N+ /\$$G+ /\$$S- /\$$I+
# /Ecode /Ocode /Udmp /Idmp

TASM=$(WINE) f:/bp/bin/tasm.exe 

CREWCONVS=data/conv0001.dta data/conv0002.dta data/conv0003.dta data/conv0004.dta data/conv0005.dta data/conv0006.dta
RACECONVS=data/conv1001.dta data/conv1002.dta data/conv1003.dta data/conv1004.dta data/conv1005.dta data/conv1006.dta data/conv1007.dta data/conv1008.dta data/conv1009.dta data/conv1010.dta data/conv1011.dta
SPECCONVS=data/conv1100.dta data/conv1101.dta data/conv1102.dta data/conv1103.dta
all: convmake logmake main.exe crewgen.exe intro.exe detsound.exe is.exe $(RACECONVS) $(SPECCONVS) $(CREWCONVS) data/log.dta datafiles # sndcfg.exe

convmake: makedata/convmake.d makedata/data.d
	dmd makedata/convmake.d makedata/data.d

logmake: makedata/logmake.d makedata/data.d
	dmd makedata/logmake.d makedata/data.d

data/conv0001.dta: makedata/crewcon1.txt convmake
	./convmake makedata/crewcon1.txt data/conv0001
data/conv0002.dta: makedata/crewcon2.txt convmake
	./convmake makedata/crewcon2.txt data/conv0002
data/conv0003.dta: makedata/crewcon3.txt convmake
	./convmake makedata/crewcon3.txt data/conv0003
data/conv0004.dta: makedata/crewcon4.txt convmake
	./convmake makedata/crewcon4.txt data/conv0004
data/conv0005.dta: makedata/crewcon5.txt convmake
	./convmake makedata/crewcon5.txt data/conv0005
data/conv0006.dta: makedata/crewcon6.txt convmake
	./convmake makedata/crewcon6.txt data/conv0006

data/conv1001.dta: makedata/sengcon1.txt convmake
	./convmake makedata/sengcon1.txt data/conv1001
data/conv1002.dta: makedata/dpahcon1.txt convmake
	./convmake makedata/dpahcon1.txt data/conv1002
data/conv1003.dta: makedata/aardcon1.txt convmake
	./convmake makedata/aardcon1.txt data/conv1003
data/conv1004.dta: makedata/ermicon1.txt convmake
	./convmake makedata/ermicon1.txt data/conv1004
data/conv1005.dta: makedata/titecon1.txt convmake
	./convmake makedata/titecon1.txt data/conv1005
data/conv1006.dta: makedata/quacon1.txt convmake
	./convmake makedata/quacon1.txt  data/conv1006
data/conv1007.dta: makedata/scavcon1.txt convmake
	./convmake makedata/scavcon1.txt data/conv1007
data/conv1008.dta: makedata/iconcon1.txt convmake
	./convmake makedata/iconcon1.txt data/conv1008
data/conv1009.dta: makedata/guilcon1.txt convmake
	./convmake makedata/guilcon1.txt data/conv1009
data/conv1010.dta: makedata/mochcon1.txt convmake
	./convmake makedata/mochcon1.txt data/conv1010
data/conv1011.dta: makedata/voidcon1.txt convmake
	./convmake makedata/voidcon1.txt data/conv1011
data/conv1100.dta: makedata/tek2con1.txt convmake
	./convmake makedata/tek2con1.txt data/conv1100
data/conv1101.dta: makedata/tek3con1.txt convmake
	./convmake makedata/tek3con1.txt data/conv1101
data/conv1102.dta: makedata/tek4con1.txt convmake
	./convmake makedata/tek4con1.txt data/conv1102
data/conv1103.dta: makedata/tek5con1.txt convmake
	./convmake makedata/tek5con1.txt data/conv1103

data/log.dta: makedata/logs.txt logmake
	./logmake makedata/logs.txt data/titles.dta data/log.dta 

# /CD /$$N+ /$$G+ /$$S- /$$I- 
main.exe: $(MAINSRC) code/mover.obj code/vga256.obj
	$(TPC) $(TPCFLAGS) code\\main.pas #| linefix
	$(FIXNAMES) code
	cat code/main.exe code/main.ovr > main.exe
	touch main.exe --reference=code/main.exe

crewgen.exe: $(CREWGENSRC) code/mover.obj code/vga256.obj
	$(TPC) $(TPCFLAGS) code\\crewgen.pas #| linefix
	$(FIXNAMES) code
	cp code/crewgen.exe ./crewgen.exe

intro.exe: $(INTROSRC) code/scroller.obj code/vga256.obj
	$(TPC) $(TPCFLAGS) code\\intro.pas #| linefix
	$(FIXNAMES) code
	cp code/intro.exe ./intro.exe

is.exe: $(ISSRC)
	$(TPC) $(TPCFLAGS) code\\is.pas #| linefix
	$(FIXNAMES) code
	cp code/is.exe ./is.exe

sndcfg.exe: code/sndcfg.pas #makedata/win.pas
	$(TPC) $(TPCFLAGS) code\\sndcfg.pas #| linefix
	$(FIXNAMES) code
	cp code/sndcfg.exe ./sndcfg.exe

detsound.exe: code/detsound.pas
	$(TPC) $(TPCFLAGS) code\\detsound.pas #| linefix
	$(FIXNAMES) code
	cp code/detsound.exe ./detsound.exe

code/graphics.obj: code/graphics.asm
	$(TASM) code\\graphics.asm code\\
	$(FIXNAMES) code
code/mouse.obj: code/mouse.asm
	$(TASM) code\\mouse.asm code\\
	$(FIXNAMES) code
code/mover.obj: code/mover.asm
	$(TASM) code\\mover.asm code\\
	$(FIXNAMES) code
code/mover2.obj: code/mover2.asm
	$(TASM) code\\mover2.asm code\\
	$(FIXNAMES) code
code/scroller.obj: code/scroller.asm
	$(TASM) code\\scroller.asm code\\
	$(FIXNAMES) code

clean:
	rm -f code/*.tpu code/*.exe code/*.ovr code/*.map
	rm -f code/graphics.obj code/mourse.obj code/mover.obj code/mover2.obj code/scroller.obj
	rm -f main.exe crewgen.exe intro.exe
	rm -f convmake logmake
	rm -f data/iteminfo.dta data/creation.dta data/cargo.dta data/scan.dta data/sysnames.dta data/contact0.dta data/crew.dta data/artifact.dta data/elements.dta data/event.dta

code/itemmake.exe: makedata/itemmake.pas
	$(TPC) $(TPCTOOLFLAGS) makedata\\itemmake.pas #| linefix
	$(FIXNAMES) code
code/creamake.exe: makedata/creamake.pas
	$(TPC) $(TPCTOOLFLAGS) makedata\\creamake.pas #| linefix
	$(FIXNAMES) code
code/cargmake.exe: makedata/cargmake.pas
	$(TPC) $(TPCTOOLFLAGS) makedata\\cargmake.pas #| linefix
	$(FIXNAMES) code
code/scanmake.exe: makedata/scanmake.pas
	$(TPC) $(TPCTOOLFLAGS) makedata\\scanmake.pas #| linefix
	$(FIXNAMES) code
code/sysmake.exe: makedata/sysmake.pas
	$(TPC) $(TPCTOOLFLAGS) makedata\\sysmake.pas #| linefix
	$(FIXNAMES) code
code/aliemake.exe: makedata/aliemake.pas
	$(TPC) $(TPCTOOLFLAGS) makedata\\aliemake.pas #| linefix
	$(FIXNAMES) code
code/crewmake.exe: makedata/crewmake.pas
	$(TPC) $(TPCTOOLFLAGS) makedata\\crewmake.pas #| linefix
	$(FIXNAMES) code
code/artimake.exe: makedata/artimake.pas
	$(TPC) $(TPCTOOLFLAGS) makedata\\artimake.pas #| linefix
	$(FIXNAMES) code
code/elemmake.exe: makedata/elemmake.pas
	$(TPC) $(TPCTOOLFLAGS) makedata\\elemmake.pas #| linefix
	$(FIXNAMES) code
code/eventmak.exe: makedata/eventmak.pas
	$(TPC) $(TPCTOOLFLAGS) makedata\\eventmak.pas #| linefix
	$(FIXNAMES) code

data/iteminfo.dta: code/itemmake.exe makedata/iteminfo.txt
	$(WINE) code/itemmake.exe
	$(FIXNAMES) code data
data/creation.dta: code/creamake.exe makedata/creation.txt
	$(WINE) code/creamake.exe
	$(FIXNAMES) code data other
data/cargo.dta: code/cargmake.exe makedata/cargo.txt
	$(WINE) code/cargmake.exe
	$(FIXNAMES) code data
data/scan.dta: code/scanmake.exe makedata/scandata.txt
	$(WINE) code/scanmake.exe
	$(FIXNAMES) code data
data/sysname.dta: code/sysmake.exe makedata/names.txt
	$(WINE) code/sysmake.exe
	$(FIXNAMES) code data
data/contact0.dta: code/aliemake.exe makedata/contact.txt
	$(WINE) code/aliemake.exe
	$(FIXNAMES) code data
data/crew.dta: code/crewmake.exe makedata/crew.txt
	$(WINE) code/crewmake.exe
	$(FIXNAMES) code data
data/artifact.dta: code/artimake.exe makedata/anom.txt
	$(WINE) code/artimake.exe
	$(FIXNAMES) code data
data/elements.dta: code/elemmake.exe makedata/element.txt
	$(WINE) code/elemmake.exe
	$(FIXNAMES) code data
data/event.dta: code/eventmak.exe makedata/event.txt
	$(WINE) code/eventmak.exe
	$(FIXNAMES) code data

datafiles: data/iteminfo.dta data/creation.dta data/cargo.dta data/scan.dta data/sysname.dta data/contact0.dta data/crew.dta data/artifact.dta data/elements.dta data/event.dta
