#include "beaverApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "ModulesApp.h"
#include "MooseSyntax.h"

template <>
InputParameters
validParams<beaverApp>()
{
  InputParameters params = validParams<MooseApp>();
  return params;
}

beaverApp::beaverApp(InputParameters parameters) : MooseApp(parameters)
{
  Moose::registerObjects(_factory);
  ModulesApp::registerObjects(_factory);
  beaverApp::registerObjects(_factory);

  Moose::associateSyntax(_syntax, _action_factory);
  ModulesApp::associateSyntax(_syntax, _action_factory);
  beaverApp::associateSyntax(_syntax, _action_factory);

  Moose::registerExecFlags(_factory);
  ModulesApp::registerExecFlags(_factory);
  beaverApp::registerExecFlags(_factory);
}

beaverApp::~beaverApp() {}

void
beaverApp::registerApps()
{
  registerApp(beaverApp);
}

void
beaverApp::registerObjects(Factory & factory)
{
    Registry::registerObjectsTo(factory, {"beaverApp"});
}

void
beaverApp::associateSyntax(Syntax & /*syntax*/, ActionFactory & action_factory)
{
  Registry::registerActionsTo(action_factory, {"beaverApp"});

  /* Uncomment Syntax parameter and register your new production objects here! */
}

void
beaverApp::registerObjectDepends(Factory & /*factory*/)
{
}

void
beaverApp::associateSyntaxDepends(Syntax & /*syntax*/, ActionFactory & /*action_factory*/)
{
}

void
beaverApp::registerExecFlags(Factory & /*factory*/)
{
  /* Uncomment Factory parameter and register your new execution flags here! */
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
extern "C" void
beaverApp__registerApps()
{
  beaverApp::registerApps();
}

extern "C" void
beaverApp__registerObjects(Factory & factory)
{
  beaverApp::registerObjects(factory);
}

extern "C" void
beaverApp__associateSyntax(Syntax & syntax, ActionFactory & action_factory)
{
  beaverApp::associateSyntax(syntax, action_factory);
}

extern "C" void
beaverApp__registerExecFlags(Factory & factory)
{
  beaverApp::registerExecFlags(factory);
}
