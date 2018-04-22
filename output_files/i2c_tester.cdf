/* Quartus Prime Version 17.1.0 Build 590 10/25/2017 SJ Lite Edition */
JedecChain;
	FileRevision(JESD32A);
	DefaultMfr(6E);

	P ActionCode(Cfg)
		Device PartName(10M08SAE144) Path("C:/intelFPGA_lite/17.1/proj/output_files/") File("i2c_tester.sof") MfrSpec(OpMask(1));
	P ActionCode(Ign)
		Device PartName(10M08SAE144) MfrSpec(OpMask(0) Child_OpMask(2 3 0) FullPath("C:/intelFPGA_lite/17.1/proj/output_files/i2c_tester.pof"));

ChainEnd;

AlteraBegin;
	ChainType(JTAG);
AlteraEnd;
