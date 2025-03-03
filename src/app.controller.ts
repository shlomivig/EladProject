import { Body, Controller, Headers, Post } from '@nestjs/common';
import { AppService, BaseReponse } from './app.service';

@Controller('Run')
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Post()
  async run(@Headers() headers: Record<string, string>, @Body() body:any): Promise<BaseReponse> {

    let token = headers.token || "";
    let action = body.action || "";
    let params = body.params || "";
    
    if(action == 'Login'){
      setTimeout(async() => {
        await this.appService.runSP("", "CheckTokens", "");
      }, 10 * 60 * 1000);
    }

    return await this.appService.runSP(token, action, JSON.stringify(params));
  }
}
