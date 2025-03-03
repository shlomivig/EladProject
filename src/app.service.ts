import { Injectable } from '@nestjs/common';
import * as sql from 'mssql';

@Injectable()
export class AppService {

  async runSP(token: string, action: string, params: string): Promise<BaseReponse> {
    let res = new BaseReponse();
    let port = process.env.DB_PORT;
    try {
        const pool = await sql.connect({
          user: process.env.DB_USER,
          password: process.env.DB_PASSWORD,
          server: process.env.DB_SERVER,
          port: Number(port),
          database: process.env.DB_NAME,
            options: { encrypt: false, trustServerCertificate: true }
        });
        
        let request = pool.request()
        if(token.length > 2){
          request.input('token', sql.NVarChar, token);
        }
            
        if (params.length> 2) {
            request.input('params', sql.NVarChar, params);
        }

        let result = await request.execute(`sp${action}`);

        res.data = result.recordsets;
        res.errors = { code: 0, msg: '' };

    } catch (error) {
        console.error("Query Failed:", error);
        res.errors = { code: 1, msg: error.message };
    }

    return res;
  }

}

export class BaseReponse{
  data:any;
  errors: {code:number, msg:string}
}