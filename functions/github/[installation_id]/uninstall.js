import { App, AuthResult, GitHub } from "@/utils";
import { PrismaD1 } from '@prisma/adapter-d1';
import { PrismaClient } from '@prisma/client';

export async function onRequestGet(context) {
    const {
        request, // same as existing Worker API
        env, // same as existing Worker API
        params, // if filename includes [id] or [[path]]
        waitUntil, // same as ctx.waitUntil in existing Worker API
        next, // used for middleware or to fetch assets
        data, // arbitrary space for passing data between middlewares
    } = context
    const adapter = new PrismaD1(env.d1db)
    const prisma = new PrismaClient({
        adapter,
        transactionOptions: {
            maxWait: 1500, // default: 2000
            timeout: 2000, // default: 5000
        },
    })
    const { err, result, session } = await (new App(request, prisma)).authenticate()
    if (result !== AuthResult.AUTHENTICATED) {
        return Response.json({ ok: false, error: { message: err }, result })
    }
    try {
        const where = {
            memberEmail: session.memberEmail,
            installationId: parseInt(params.installation_id, 10),
        }
        const app = await prisma.github_apps.findUniqueOrThrow({ where })
        const gh = new GitHub(app.accessToken)
        const result = await gh.revokeToken()
        if ([204, 401].includes(result.status)) {
            const response = await prisma.github_apps.delete({ where })
            console.log(`/github/uninstall session kid=${session.token}`, response)

            return Response.json(response)
        }

        return Response.json(result)
    } catch (err) {
        console.error(err)

        return Response.json({ ok: false, error: { message: err }, result: AuthResult.REVOKED })
    }
}
