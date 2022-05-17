try:
    from robot.api.deco import keyword
    from webdriver_manager.chrome import ChromeDriverManager
    ROBOT = False
except Exception:
    ROBOT = False

class HelpLib():

    @keyword("get chromedriver path")
    def get_chromedriver_path(self):
        driver_path = ChromeDriverManager().install()
        print(driver_path)
        return  driver_path
