package egovframework.third.homework.web;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class ViewController {
	
	private static final Logger log = LoggerFactory.getLogger(ViewController.class);

//    @Resource(name = "userService")
//    protected UserService userService;
	
	// 로그인 페이지
	@RequestMapping(value = "/login.do")
	public String loginPage() throws Exception {
		return "login";
	}
	
	// 회원가입 페이지
	@RequestMapping(value = "/register.do")
	public String registerPage() throws Exception {
		return "register";
	}
	
	// 설문조사 목록 페이지
	@RequestMapping(value = "/surveyList.do")
	public String surveyListPage() throws Exception {
		return "surveyList";
	}
	
	// 글쓰기 폼 페이지
	@RequestMapping(value = "/surveyForm.do")
	public String showSurveyForm() {
		return "surveyForm";
	}
	
}
