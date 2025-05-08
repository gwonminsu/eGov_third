package egovframework.third.homework.web;

import javax.annotation.Resource;
import javax.servlet.http.HttpSession;

import org.egovframe.rte.fdl.property.EgovPropertyService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import egovframework.third.homework.service.UserVO;

@Controller
public class ViewController {
	
	private static final Logger log = LoggerFactory.getLogger(ViewController.class);
	
    @Resource(name="propertiesService")
    private EgovPropertyService prop;
	
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
	public String surveyListPage(Model model) throws Exception {
	    model.addAttribute("pageUnit", prop.getInt("pageUnit"));
	    model.addAttribute("pageSize", prop.getInt("pageSize"));
		return "surveyList";
	}
	
	// 설문조사 관리 페이지
	@RequestMapping(value = "/surveyManage.do")
	public String surveyManagePage(Model model, HttpSession session, RedirectAttributes rt) throws Exception {
		UserVO me = (UserVO) session.getAttribute("loginUser");
        // 로그인 안 했거나, 관리자 아니면
        if (me == null || !me.isRole()) {
            rt.addFlashAttribute("errorMsg", "관리자 권한이 필요합니다.");
            return "redirect:/surveyList.do";
        }
	    model.addAttribute("pageUnit", prop.getInt("pageUnit"));
	    model.addAttribute("pageSize", prop.getInt("pageSize"));
		return "surveyManage";
	}
	
	// 설문조사 폼 페이지
	@RequestMapping(value = "/surveyForm.do")
	public String showSurveyForm() {
		return "surveyForm";
	}
	
	// 설문조사 상세 페이지
	@RequestMapping(value = "/surveyDetail.do")
	public String showSurveyDetail() {
		return "surveyDetail";
	}
	
	// 설문조사 참여 페이지
	@RequestMapping(value = "/surveyParticipate.do")
	public String showSurveyParticipate() {
		return "surveyParticipate";
	}
	
}
