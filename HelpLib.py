try:
    from ast import keyword
    from robot.api.deco import keyword
    from selenium import webdriver
    from webdriver_manager.chrome import ChromeDriverManager
    ROBOT = False
except Exception:
    ROBOT = False

class HelpLib():

    def __init__(self) -> None:
        pass

    @keyword("get chromedriver path")
    def get_chromedriver_path(self):
        driver_path = ChromeDriverManager().install()
        print(driver_path)
        return  driver_path
