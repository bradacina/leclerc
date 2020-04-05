import httpclient, logging, tables, strutils, nre

const UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.132 Safari/537.36 OPR/67.0.3575.97"
const HoursUrl = "https://fd9-courses.leclercdrive.fr/magasin-045722-Thionville-Basse-Ham/choix-horaire.aspx" 

proc readCookie() : string =
    let f = open(".cookie")
    result = f.readLine()
    f.close

proc writeCookie(cookie:string) =
    let f = open(".cookie", fmWrite)
    f.write(cookie)
    f.close

proc getPage*(): Response =
    let cookie = readCookie()
    
    if not cookie.len > 0:
        quit("Auth cookie was empty. Please place it in the .cookie file.")

    info("Checking availability")

    var client = newHttpClient(UserAgent)

    client.headers.add("Accept","text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9")
    client.headers.add("Accept-Language", "en-US,en;q=0.9")
    client.headers.add("Cache-Control","max-age=0")
    client.headers.add("Connection","keep-alive")
    client.headers.add("Cookie", cookie)
    client.headers.add("Sec-Fetch-Dest", "document")
    client.headers.add("Sec-Fetch-Mode", "navigate")
    client.headers.add("Sec-Fetch-Site", "none")
    client.headers.add("Sec-Fetch-User", "?1")
    client.headers.add("Upgrade-Insecure-Requests", "1")

    try:
        var response = client.request(HoursUrl, HttpGet)

        for cookie in response.headers.table["set-cookie"]:
            if cookie.contains(".XPRSDRVAUTH"):
                info("SET-COOKIE wants to change Auth token ", cookie)
                writeCookie(cookie.split(";")[0] & ";")

        result = response
    except OSError:
        warn(getCurrentExceptionMsg())
    
    client.close()

proc getHours*(page: string): seq[string] =
    for m in findAll(page, re"""(?s)(?U)input type="radio" value="(.+)".+>""").items:
        if not m.contains("disabled"):
            result.add(m.find(re"""(?U)value="(.+)"""").get.captures[0])

