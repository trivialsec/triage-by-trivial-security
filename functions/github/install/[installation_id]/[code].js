import { PrismaD1 } from '@prisma/adapter-d1';
import { PrismaClient } from '@prisma/client';
import { App, AuthResult, GitHub, pbkdf2 } from "../../../../src/utils";

const appExpiryPeriod = (86400000 * 365 * 10)  // 10 years

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
    const app = new App(request, prisma)
    let err, result, session;
    const authToken = request.headers.get('x-trivialsec')
    if (!!authToken.trim()) {
        ({ err, result, session } = await app.authenticate())
        if (result !== AuthResult.AUTHENTICATED) {
            return Response.json({ err, result })
        }
    }
    try {
        if (params?.code && params?.installation_id) {
            const method = "POST"
            const url = new URL("https://github.com/login/oauth/access_token")

            url.search = new URLSearchParams({
                code: params.code,
                client_id: env.GITHUB_APP_CLIENT_ID,
                client_secret: env.GITHUB_APP_CLIENT_SECRET,
            }).toString()

            const resp = await fetch(url, { method })
            const text = await resp.text()
            const data = Object.fromEntries(text.split('&').map(item => item.split('=').map(decodeURIComponent)))
            console.log(`installationId=${params.installation_id} data=${JSON.stringify(data)}`)
            if (data?.error) {
                throw new Error(data.error)
            }
            if (!data?.access_token) {
                throw new Error('OAuth response invalid')
            }
        } else {
            return Response.json({ 'err': 'OAuth authorization code not provided' })
        }

        const created = (new Date()).getTime()
        const expires = appExpiryPeriod + created
        const response = { installationId: params.installation_id, session: {}, member: {} }
        const memberExists = await app.memberExists()
        if (!memberExists) {
            const gh = new GitHub(data.access_token)
            const ghUserData = await gh.getUser()
            const words = ghUserData.email.split(' ')
            const firstName = words.shift()
            const lastName = words.join(' ') || ''
            const memberInfo = await prisma.members.create({
                orgName: ghUserData.company,
                email: ghUserData.email,
                passwordHash: await pbkdf2(data.access_token),
                firstName,
                lastName
            })
            console.log(`/github/install register email=${ghUserData.email}`, memberInfo)

            const token = crypto.randomUUID()
            const authn_ip = request.headers.get('cf-connecting-ip')
            const authn_ua = request.headers.get('user-agent')
            const expiry = created + (86400000 * 30) // 30 days
            const secret = Array.from(new Uint8Array(await crypto.subtle.digest("SHA-1", crypto.getRandomValues(new Uint32Array(26))))).map(b => b.toString(16).padStart(2, "0")).join("")
            session = {
                kid: token,
                memberEmail: ghUserData.email,
                expiry,
                issued: created,
                secret,
                authn_ip,
                authn_ua
            }
            const sessionInfo = await prisma.sessions.create(session)
            console.log(`/github/install session kid=${token}`, sessionInfo)
            response.session.token = token
            response.session.expiry = expiry
            response.member.email = ghUserData.email
            response.member.orgName = ghUserData.company
            response.member.firstName = firstName
            response.member.lastName = lastName
        }
        const GHAppInfo = await prisma.sessions.create({
            installationId: params.installation_id,
            memberEmail: session.memberEmail,
            accessToken: data.access_token,
            created,
            expires
        })
        console.log(`/github/install installationId=${params.installation_id}`, GHAppInfo)

        return Response.json(response)
    } catch (err) {
        console.error(err)

        return Response.json({ ok: false, result: AuthResult.REVOKED })
    }
}
