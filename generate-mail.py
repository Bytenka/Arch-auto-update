from datetime import datetime
import sys

mailTemplatePath = "./mail/mail_template.html"
mailStylePath    = "./mail/mail_style.css"

def generate_mail():
    # Expected argv sequence:
        #### generate_mail.py [DATE_START] [DATE_END] [STATUS:success|failed] [STATUS_MESSAGE] [LOG_FILE]

    mail = ""
    with open(mailTemplatePath, "r") as templateFile:
        mail = templateFile.read()

    mail = mail.replace("GEN_STYLE",        generate_style(), 1)
    mail = mail.replace("GEN_DATE_START",   generate_date_start(sys.argv[1]), 1)
    mail = mail.replace("GEN_TIME_TAKEN",   generate_time_taken(sys.argv[1], sys.argv[2]), 1)
    mail = mail.replace("GEN_BANNER",       generate_banner(sys.argv[3] == "success", sys.argv[4]), 1)
    mail = mail.replace("GEN_LOG",          generate_log(sys.argv[5]), 1)
    mail = mail.replace("GEN_LOG_LOCATION", sys.argv[5], 1)

    print(mail) # Send to stdout as a way to return what has been generated


def generate_date_start(date: str):
    return datetime.fromtimestamp(int(date)).strftime("%H:%M:%S on %a %d, %Y")


def generate_time_taken(start: str, end: str):
    st = datetime.utcfromtimestamp(int(start))
    en = datetime.utcfromtimestamp(int(end))
    return str(abs((en - st)))


def generate_style():
    style = "<style>\nDATA</style>"

    with open(mailStylePath, "r") as styleCss:
        style = style.replace("DATA", styleCss.read())

    return style


def generate_banner(success: bool, msg: str):
    value = "FAILED"
    color1="rgb(184, 15, 15)"
    color2="rgb(214, 70, 70)"

    if (success):
        value="SUCCEEDED"
        color1="rgb(18, 122, 18)"
        color2="rgb(68, 163, 68)"

    bannerHead = "<div class=\"update-status\" style=\"background-color: COLOR1;\">VALUE</div>"
    bannerHead = bannerHead.replace("COLOR1", color1).replace("VALUE", value)
    bannerBody = "<p class=\"update-status-description\" style=\"background-color: COLOR2;\">MSG</p>"
    bannerBody = bannerBody.replace("COLOR2", color2).replace("MSG", msg.replace("\\n", "<br>"))

    return "<div>HEAD\nBODY</div>".replace("HEAD", bannerHead).replace("BODY", bannerBody)


def generate_log(logFile: str):
    log = ""
    with open(logFile, "r") as lf:
        log = lf.read().replace("\n", "<br>")
    
    return "<code class=\"code-block\">LOG</code>".replace("LOG", log)


generate_mail()
