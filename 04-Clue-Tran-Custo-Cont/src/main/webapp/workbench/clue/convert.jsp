<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
String path = request.getContextPath();
String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/";

String id = request.getParameter("id");
String fullname = request.getParameter("fullname");
String appellation = request.getParameter("appellation");
String company = request.getParameter("company");
String owner = request.getParameter("owner");
%>

<html>
<head>
	<base href="<%=basePath%>"/>
	<meta charset="UTF-8">

<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>


<link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet" />
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>

<script type="text/javascript">
	$(function(){

		//引用bootstrap的日期选择器
		$(".time").datetimepicker({
			minView: "month",
			language: "zh-CN",
			format: "yyyy-mm-dd",
			autoclose: true,
			today: true,
			pickerPosition: "bottom-left"
		})

		$("#isCreateTransaction").click(function(){
			if(this.checked){
				$("#create-transaction2").show(200);
			}else{
				$("#create-transaction2").hide(200);
			}
		});

		//为创建交易时的搜索市场活动源绑定事件
		$("#openSearchModalBtn").click(function () {
			$("#searchActivityModal").modal("show");
		});

		//模糊查询市场活动源绑定事件
		$("#search-condition").keydown(function (event) {
			if(event.keyCode==13){
				loadActivity();
				return false;
			}
		})

		//为提交(市场活动源)按钮绑定事件,填充市场活动源(市场活动名字和该id)
		$("#submitActivityBtn").click(function(){
			var id = $("input[name=radioItem]:checked").val();

			$("#activityId").val(id)
			$("#activityName").val($("#"+id).html());
			$("#searchActivityModal").modal("hide");
		})

		//转换按钮绑定事件
		$("#convertBtn").click(function () {
			/*
				提交到后台执行线索转换的操作, 应该发出传统请求
				请求结束后,最终响应回线索列表页

				根据"为客户创建交易"的复选框有没有选上来判断是否需要进行创建交易
			 */
			$("#tranForm").submit();
		})

	});

	//绑定关联的模态窗口加载市场活动
	function loadActivity() {
		$("#activityBody").empty();
		//用于选择绑定市场活动与线索的窗口
		if($.trim($("#search-condition").val()) != '' ){
			$.ajax({
				url : "workbench/clue/getActivityListInRelation.do",
				data : {"condition":$("#search-condition").val(),"clueId":"${param.id}"},
				dataType : "json",
				success : function(data){
					if(data.success){
						$.each(data.activityList,function (i,n) {
							$("#activityBody").append(
									'<tr>' +
									'<td><input type="radio" name="radioItem" value="'+n.id+'"/></td>' +
									'<td id="'+n.id+'">'+n.name+'</td>' +
									'<td>'+n.startDate+'</td>' +
									'<td>'+n.endDate+'</td>' +
									'<td>'+n.owner+'</td>' +
									'</tr>'
							)
						})
					}
				}
			})
		}
	}


</script>

</head>
<body>
	
	<!-- 搜索市场活动的模态窗口 -->
	<div class="modal fade" id="searchActivityModal" role="dialog" >
		<div class="modal-dialog" role="document" style="width: 90%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">搜索市场活动</h4>
				</div>
				<div class="modal-body">
					<div class="btn-group" style="position: relative; top: 18%; left: 8px;">
						<form class="form-inline" role="form">
						  <div class="form-group has-feedback">
						    <input type="text" class="form-control" style="width: 300px;" id="search-condition" placeholder="请输入市场活动名称，支持模糊查询">
						    <span class="glyphicon glyphicon-search form-control-feedback"></span>
						  </div>
						</form>
					</div>
					<table id="activityTable" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
						<thead>
							<tr style="color: #B3B3B3;">
								<td></td>
								<td>名称</td>
								<td>开始日期</td>
								<td>结束日期</td>
								<td>所有者</td>
								<td></td>
							</tr>
						</thead>
						<tbody id="activityBody">
							<!--ajax塞入数据-->
						</tbody>
					</table>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
					<button type="button" class="btn btn-primary" id="submitActivityBtn">提交</button>
				</div>
			</div>
		</div>
	</div>

	<div id="title" class="page-header" style="position: relative; left: 20px;">
		<h4>转换线索 <small><%=fullname%><%=appellation%>-<%=company%></small></h4>
	</div>
	<div id="create-customer" style="position: relative; left: 40px; height: 35px;">
		新建客户：<%=company%>
	</div>
	<div id="create-contact" style="position: relative; left: 40px; height: 35px;">
		新建联系人：${param.fullname}${param.appellation}
	</div>
	<div id="create-transaction1" style="position: relative; left: 40px; height: 35px; top: 25px;">
		<input type="checkbox" id="isCreateTransaction"/>
		为客户创建交易
	</div>
	<div id="create-transaction2" style="position: relative; left: 40px; top: 20px; width: 80%; background-color: #F7F7F7; display: none;" >
	
		<form id="tranForm" method="post" action="workbench/clue/convert.do">
			<input type="hidden" name="clueId" value="<%=id%>">
		  <div class="form-group" style="width: 400px; position: relative; left: 20px;">
		    <label for="amountOfMoney">金额</label>
		    <input type="text" class="form-control" name="money" id="amountOfMoney">
		  </div>
		  <div class="form-group" style="width: 400px;position: relative; left: 20px;">
		    <label for="tradeName">交易名称</label>
		    <input type="text" class="form-control" name="name" id="tradeName" value="<%=company%>-">
		  </div>
		  <div class="form-group" style="width: 400px;position: relative; left: 20px;">
		    <label for="expectedClosingDate">预计成交日期</label>
		    <input type="text" class="form-control time"  name="expectedDate" id="expectedClosingDate" readonly>
		  </div>
		  <div class="form-group" style="width: 400px;position: relative; left: 20px;">
		    <label for="stage">阶段</label>
		    <select id="stage"  class="form-control" name="stage">
		    	<option></option>
		    	<c:forEach items="${stageList}" var="s">
					<option value="${s.value}">${s.text}</option>
				</c:forEach>
		    </select>
		  </div>
		  <div class="form-group" style="width: 400px;position: relative; left: 20px;">
		    <label for="activity">市场活动源&nbsp;&nbsp;<a href="javascript:void(0);" id="openSearchModalBtn" style="text-decoration: none;"><span class="glyphicon glyphicon-search"></span></a></label>
		    <input type="text" class="form-control" id="activityName" placeholder="点击上面搜索" readonly>
			  <input type="hidden" name="activityId" id="activityId"/>
		  </div>
		</form>
		
	</div>
	
	<div id="owner" style="position: relative; left: 40px; height: 35px; top: 50px;">
		记录的所有者：<br>
		<b>${param.owner}</b>
	</div>
	<div id="operation" style="position: relative; left: 40px; height: 35px; top: 100px;">
		<input class="btn btn-primary" type="button" id="convertBtn" value="转换">
		&nbsp;&nbsp;&nbsp;&nbsp;
		<input class="btn btn-default" type="button" value="取消">
	</div>
</body>
</html>