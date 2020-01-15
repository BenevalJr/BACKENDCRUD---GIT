library CrudExampleHorseIsapiServer;

uses
  Horse.ISAPI,
  Web.Win.ISAPIApp,
  Horse.Jhonson,
  Horse.CORS,
  System.JSON,
  MyJSONObjectHelper in '..\Src\Lib\MyJSONObjectHelper.pas',
  CrudExampleHorseServer.Model.Entidade.ConfigApp in '..\Src\Model\Entidade\CrudExampleHorseServer.Model.Entidade.ConfigApp.pas',
  CrudExampleHorseServer.Model.Entidade.Autorization in '..\Src\Model\Entidade\CrudExampleHorseServer.Model.Entidade.Autorization.pas',
  CrudExampleHorseServer.Model.Entidade.Cadastro in '..\Src\Model\Entidade\CrudExampleHorseServer.Model.Entidade.Cadastro.pas',
  CrudExampleHorseServer.Model.Conexao.DB in '..\Src\Model\CrudExampleHorseServer.Model.Conexao.DB.pas',
  CrudExampleHorseServer.Model.DAO.Cadastro in '..\Src\Model\DAO\CrudExampleHorseServer.Model.DAO.Cadastro.pas',
  CrudExampleHorseServer.Controller in '..\Src\Controller\CrudExampleHorseServer.Controller.pas',
  CrudExampleHorseServer.Controller.Constants in '..\Src\Controller\CrudExampleHorseServer.Controller.Constants.pas',
  CrudExampleHorseServer.Controller.Cadastro in '..\Src\Controller\CrudExampleHorseServer.Controller.Cadastro.pas';

{$R *.res}

exports
  GetExtensionVersion,
  HttpExtensionProc,
  TerminateExtension;

var
  App: THorse;

begin
  App := THorse.Create;
  App.Use(Jhonson);
  App.Use(CORS);
  TController.New.AppRegister(App);
  App.Start;
end.
