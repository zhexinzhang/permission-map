# COPES

This repository contains COPES (COllect PErmissionS), a tool to extract
permission checks from the Android Framework.

This tool has initialiy been developed for the experiments in the following
research papers:

- Alexandre Bartel, Jacques Klein, Martin Monperrus, Yves Le Traon: [Static
 Analysis for Extracting Permission Checks of a Large Scale Framework: The
 Challenges And Solutions for Analyzing Android](https://orbilu.uni.lu/bitstream/10993/20036/1/TSE_Alex_2014%20%281%29.pdf), in IEEE Transactions of
 Software Engineering (TSE), 2014

- Alexandre Bartel, Jacques Klein, Martin Monperrus, Yves Le Traon:
 Automatically Securing Permission-Based Software by Reducing the Attack
 Surface: An Application to Android, in IEEE/ACM International Conference on
 Automated Software Engineering (ASE), Essen, Germany, 2012 

# Dependencies

COPES relies on Soot:  [https://github.com/Sable/soot]

# How to compile?

1. Import COPES in eclipse
2. Import Soot and all its dependencies
3. Eclipse should compile COPES in ./bin/

# How to use? 

Use the following scripts:
- ./redirectAndroidRemoteCalls/run.sh
- ./entryPointWrapper/runGenerateClassWrappersWithSoot.sh
- ./findPermissionChecks/runFindPermissionChecks.sh
