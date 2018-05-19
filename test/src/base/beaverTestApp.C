//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html
#include "beaverTestApp.h"
#include "beaverApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "MooseSyntax.h"
#include "ModulesApp.h"

template <>
InputParameters
validParams<beaverTestApp>()
{
  InputParameters params = validParams<beaverApp>();
  return params;
}

beaverTestApp::beaverTestApp(InputParameters parameters) : MooseApp(parameters)
{
  Moose::registerObjects(_factory);
  ModulesApp::registerObjects(_factory);
  beaverApp::registerObjectDepends(_factory);
  beaverApp::registerObjects(_factory);

  Moose::associateSyntax(_syntax, _action_factory);
  ModulesApp::associateSyntax(_syntax, _action_factory);
  beaverApp::associateSyntaxDepends(_syntax, _action_factory);
  beaverApp::associateSyntax(_syntax, _action_factory);

  Moose::registerExecFlags(_factory);
  ModulesApp::registerExecFlags(_factory);
  beaverApp::registerExecFlags(_factory);

  bool use_test_objs = getParam<bool>("allow_test_objects");
  if (use_test_objs)
  {
    beaverTestApp::registerObjects(_factory);
    beaverTestApp::associateSyntax(_syntax, _action_factory);
    beaverTestApp::registerExecFlags(_factory);
  }
}

beaverTestApp::~beaverTestApp() {}

void
beaverTestApp::registerApps()
{
  registerApp(beaverApp);
  registerApp(beaverTestApp);
}

void
beaverTestApp::registerObjects(Factory & /*factory*/)
{
  /* Uncomment Factory parameter and register your new test objects here! */
}

void
beaverTestApp::associateSyntax(Syntax & /*syntax*/, ActionFactory & /*action_factory*/)
{
  /* Uncomment Syntax and ActionFactory parameters and register your new test objects here! */
}

void
beaverTestApp::registerExecFlags(Factory & /*factory*/)
{
  /* Uncomment Factory parameter and register your new execute flags here! */
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
// External entry point for dynamic application loading
extern "C" void
beaverTestApp__registerApps()
{
  beaverTestApp::registerApps();
}

// External entry point for dynamic object registration
extern "C" void
beaverTestApp__registerObjects(Factory & factory)
{
  beaverTestApp::registerObjects(factory);
}

// External entry point for dynamic syntax association
extern "C" void
beaverTestApp__associateSyntax(Syntax & syntax, ActionFactory & action_factory)
{
  beaverTestApp::associateSyntax(syntax, action_factory);
}

// External entry point for dynamic execute flag loading
extern "C" void
beaverTestApp__registerExecFlags(Factory & factory)
{
  beaverTestApp::registerExecFlags(factory);
}
