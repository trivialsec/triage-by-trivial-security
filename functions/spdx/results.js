import { App, AuthResult } from "@/utils";
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
    const res = await prisma.spdx.findMany({
        where: {
            memberEmail: session.memberEmail,
        },
        omit: {
            memberEmail: true,
        },
        include: {
            repo: true,
        },
        take: 100,
        orderBy: {
            createdAt: 'desc',
        },
    })
    const spdx = res.map(spdxData => {
        spdxData.packages = JSON.parse(spdxData.packagesJSON)
        spdxData.relationships = JSON.parse(spdxData.relationshipsJSON)
        delete spdxData.packagesJSON
        delete spdxData.relationshipsJSON
        return spdxData
    })

    return Response.json({ spdx })
}
