/////////////////////////////////////////////////////////////////////////////
// Copyright 2004 The RenderMan Repository.  All Rights Reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are
// met:
//
// * Redistributions of source code must retain the above copyright
//   notice, this list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright
//   notice, this list of conditions and the following disclaimer in the
//   documentation and/or other materials provided with the distribution.
// * Neither the name of The RenderMan Repository nor the names of its contributors
//   may be used to endorse or promote products derived from this software
//   without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
// OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
// LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
// THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
// "RenderMan" is a trademark of Pixar, Inc.
// "Gelato" is a trademark of NVIDIA Corporation
//
// (This is the Modified BSD License)
/////////////////////////////////////////////////////////////////////////////

/*
 *   $Id: rslParserMain.cpp,v 1.29 2004/12/20 19:50:58 tal Exp $
 */

/* main file for rslparser */

#include <iostream>
#include <string>
#include "rslParser.h"
//#include "emitIndent.h"
#include <string.h>

#include <stdlib.h>

//#if 1 // symbtable stuff
//extern "C" {
//#include "symtable.h"

int Nest;
int Debug;
//}
//#endif


int parseTree (Node*);
bool Node::emitGsl = 0;
bool Node::shaderNeeds_COs = 0;
int Node::translateError = 0;
std::string Node::shaderMP = "";
std::string Indirect = "defaultIndirect";
std::string Occlusion = "defaultOcclusion";

Node::Type Node::lastType = Node::Not;
int emitIndent::level = 0;

extern "C" int yydebug;


//std::string Node::illum_category = "";

#if 0
std::string process_args (int argc, char**argv) {
  std::string args;

  for (int i = 1; i < argc
#endif

int main(int argc, char** argv)
{
  int version_Majnum = 0;
  int version_Minnum = 8;
  int version_subnum = 3;
  char versa[10];
  std::string args;
  std::string fname;
  std::string pversion = "\n\trsl2gsl translator version: ";
  bool dumpParseTree = 0;
  bool verbose = 0;
  bool emitGsl = 0;
  Nest = 0;
  Debug = 0;

  yydebug = 0;

  //sprintf (versa, "%d.%d", version_Majnum, version_Minnum);
  sprintf (versa, "%d.%d.%d", version_Majnum, version_Minnum, version_subnum);
  pversion += versa ;//+ "\n";
  pversion += "\n";

  //args = process_args (argc, argv);
  //dump out version number
  std::cerr << pversion << std::endl;

  for (int i = 1; i < argc; i++) {
    if (argv[i][0] == '-') {
      //ok have an argument
      if (strcmp (argv[i], "-dt") == 0)
	dumpParseTree = 1;
      else if (strncmp (argv[i], "-v", 2) == 0)
	verbose = 1;
      else if (strcmp (argv[i], "-gsl") == 0)
	emitGsl = 1;
      else if (strcmp (argv[i], "-h") == 0 || strcmp (argv[i], "-help") == 0) {
	//give help
	return 0;
      }
      else if (strcmp (argv[i], "-indirect") == 0)
	Indirect = argv[++i];
      else if (strcmp (argv[i], "-occlusion") == 0) {
	Occlusion = argv[++i];
	//std::cerr << "Found occlusion set to " << Occlusion << std::endl;
      }
      else {
	//must be a cpp argument
	args += argv[i];
	if (i < argc - 2)
	  args += ' ';
      }
    }
    else { // should be last argument: filename
      fname = argv[i];
      //args += argv[i];
    }
  }
  if (verbose) {
    //std::cerr << "dumpPT " << dumpParseTree << std::endl;
    std::cerr << "args: " << args << std::endl;
  }

  Indirect = '"' + Indirect + '"';
  Occlusion = '"' + Occlusion + '"';

  if (argc >= 2) {
    std::string error;
    Node::emitGsl = emitGsl;
    Node* result = RslParse(fname, args, error, verbose);
    if (!result)  {
      std::cerr << error << std::endl;
      exit (EXIT_FAILURE);
    }
    else {

      if (dumpParseTree)
	result->dump();
      else
	parseTree (result);

      delete result;
    }
  }
#if 0
    if (argc != 2) {
	fprintf(stderr, "usage: parse shader-source\n");
	return 1;
    }
    std::string error;
    Node* result = RslParse(argv[1], error);
    if (!result) {
      std::cerr << error << std::endl;
      return 0;
    }
#if 0
    else result->dump();
#else
    //else result->emitRSL();
    parseTree (result);

#endif
    delete result;

#endif

    //std::cerr << "translate error: " << Node::translateError << std::endl;
    // will want to adjust depending on arg flags
    if (Node::translateError == 0)
      exit (EXIT_SUCCESS);
    else
      exit (EXIT_FAILURE);

}
