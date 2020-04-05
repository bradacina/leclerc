import httpclient, json, strutils

type
    TelegramBot = object
        token: string

const TelegramSendMessageUrl = "https://api.telegram.org/bot$1/sendMessage"

proc getTelegramToken(): string=
    let f = open(".telegram_bot")
    result = f.readLine()
    f.close

proc newTelegramBot*(): TelegramBot =
    result.token = getTelegramToken()


proc sendMessage*(bot: TelegramBot, message: string): Response =
    if bot.token.len == 0 or message.len == 0:
        return

    var client = newHttpClient()

    let payload = %* {
        "chat_id":"@leclerc_availability",
        "text": message
    }

    client.headers.add("Content-Type", "application/json")
    result = client.post( format(TelegramSendMessageUrl, bot.token), $payload )