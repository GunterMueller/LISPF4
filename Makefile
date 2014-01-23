
#F2C = \f2c-new\f2c
#LIB = \f2c-new\vcf2c.lib
#INCDIR = \f2c-new

#CFLAGS = -nologo -Zi -Od
CFLAGS = -nologo -O2
FFLAGS =  -onetrip -A -h

.f.c .PRECIOUS:
	$(F2C) -onetrip -A -h -E $<

BASIC.IMG : BARE.IMG script.2
	lispf4 BARE.IMG <script.2

BARE.IMG : lispf4.exe SYSATOMS script.1
	lispf4 <script.1


lispf4.exe : lispf41.obj lispf42.obj auxillary.obj
	cl $(CFLAGS) -Felispf4.exe lispf41.obj lispf42.obj auxillary.obj

#lispf41.c : lispf41.f
#	$(F2C) $(FFLAGS) $<

#lispf42.c : lispf42.f
#	$(F2C) $(FFLAGS) -E $<

#lispf41.obj : lispf41.c

#lispf41.obj : lispf41.c

clean:
	rm -zfq *~ *.o core *.obj *.bak
	rm -zfq *.pdb *.ilk *.opt

realclean: clean
	rm -zfq lispf4.exe *.img
