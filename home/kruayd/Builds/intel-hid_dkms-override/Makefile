MODNAME = intel-hid
MODVER = 0.1

obj-m += $(MODNAME).o

KDIR = /lib/modules/$(shell uname -r)/build
MDIR = /usr/src/$(MODNAME)-$(MODVER)

all:
	make -C $(KDIR) M=$(PWD) modules

clean:
	make -C $(KDIR) M=$(PWD) clean

dkmsinstall:
	mkdir -p $(MDIR)
	cp Makefile dkms.conf $(MODNAME).c $(MDIR)/.
	dkms add $(MODNAME)/$(MODVER)
	dkms build $(MODNAME)/$(MODVER)
	dkms install $(MODNAME)/$(MODVER)

dkmsuninstall:
	-rmmod $(MODNAME)
	-dkms uninstall $(MODNAME)/$(MODVER)
	-dkms remove $(MODNAME)/$(MODVER) --all
	rm -rf $(MDIR)
