<%--
Created by IntelliJ IDEA.
User: Chieh
Date: 2021/6/25
Time: 9:39
To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
String path = request.getContextPath();
String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/";
%>
<html>
<head>
	<base href="<%=basePath%>"/>
	<meta charset="UTF-8">

<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
	<link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet" />

	<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
	<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
	<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
	<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>



	<script type="text/javascript">

	//默认情况下取消和保存按钮是隐藏的
	var cancelAndSaveBtnDefault = true;
	
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

		$("#remark").focus(function(){
			if(cancelAndSaveBtnDefault){
				//设置remarkDiv的高度为130px
				$("#remarkDiv").css("height","130px");
				//显示
				$("#cancelAndSaveBtn").show("2000");
				cancelAndSaveBtnDefault = false;
			}
		});
		
		$("#cancelBtn").click(function(){
			//显示
			$("#cancelAndSaveBtn").hide();
			//设置remarkDiv的高度为130px
			$("#remarkDiv").css("height","90px");
			cancelAndSaveBtnDefault = true;
		});

		$(".myHref").mouseover(function(){
			$(this).children("span").css("color","red");
		});
		
		$(".myHref").mouseout(function(){
			$(this).children("span").css("color","#E6E6E6");
		});

		$("#remarkBody").on("mouseover",".remarkDiv",function(){
			$(this).children("div").children("div").show();
		})
		$("#remarkBody").on("mouseout",".remarkDiv",function(){
			$(this).children("div").children("div").hide();
		})


		//编辑按钮绑定事件
		$("#editBtn").click(function(){
			//获取activity对象后打开模态窗口
			$.ajax({
				url : "workbench/activity/getActivityById.do",
				data : {"id" : "${activity.id}"},
				dataType : "json",
				success : function(data){
					//加载所有者信息列表
					$("#edit-owner").empty();		//清空
					var html = "";
					$.each(data.userList, function(i, n){
						html += "<option value='"+n.id+"'>"+n.name+"</option>";
					})

					$("#edit-owner").html(html);
					$("#edit-owner").val(data.activity.owner);
					$("#edit-name").val(data.activity.name);
					$("#edit-startDate").val(data.activity.startDate);
					$("#edit-endDate").val(data.activity.endDate);
					$("#edit-cost").val(data.activity.cost)
					$("#edit-description").val(data.activity.description)

					$("#editActivityModal").modal("show");
				}
			})
		})

		//更新市场活动按钮绑定事件
		$("#updateBtn").click(function () {
			$.ajax({
				url : "workbench/activity/update.do",
				data : {
					"id" : "${activity.id}",
					"owner" : $.trim($("#edit-owner").val()),
					"name" : $.trim($("#edit-name").val()),
					"startDate" : $.trim($("#edit-startDate").val()),
					"endDate" : $.trim($("#edit-endDate").val()),
					"cost" : $.trim($("#edit-cost").val()),
					"description" : $.trim($("#edit-description").val()),
					"editBy" : "${sessionScope.user.name}"
				},
				type : "post",
				dataType: "json",
				success : function (data) {
					if(data){
						document.location.href = "workbench/activity/detail.do?id="+"${activity.id}";
					}else{
						alert("更新市场活动失败");
					}
				}
			})
		})

		//删除市场活动按钮绑定事件
		$("#deleteBtn").click(function(){
			if(confirm("确定删除选中的记录吗?")){
				$.ajax({
					url : "workbench/activity/delete.do",
					data : {"id" : "${activity.id}"},
					type : "post",
					dataType : "json",
					success : function(data){
						if (data){
							//删除成功后返回市场活动查询页面
							document.location.href = "workbench/activity/index.jsp";

						}else {
							alert("删除市场活动失败");
						}
					}
				})
			}
		})

		//保存备注按钮绑定事件
		$("#saveRemark").click(function () {
			$.ajax({
				url : "workbench/activity/saveRemark.do",
				data : {"noteContent": $("#remark").val(),"activityId" : "${activity.id}"},
				type : "post",
				dataType : "json",
				success : function(data){

					//t添加成功后动态添加到jsp页面中
					if (data.success){
						var aname = '${activity.name}';
						$("#forNewRemark").after(
								'<div id="'+data.remark.id+'" class="remarkDiv" style="height: 60px;">\n' +
								'<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">\n' +
								'<div style="position: relative; top: -40px; left: 40px;" >\n' +
								'<h5 id="content'+data.remark.id+'">'+data.remark.noteContent+'</h5>\n' +
								'<font color="gray">市场活动</font> <font color="gray">-</font> <b>'+aname+'</b> <small style="color: gray;" id="small'+data.remark.id+'"> '+data.remark.createTime+' 由 '+data.remark.createBy+'</small>\n' +
								'<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">\n' +
								'<a class="myHref" href="javascript:void(0);" onclick="editRemark(\''+data.remark.id+'\')"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #FF9797;"></span></a>\n' +
								'&nbsp;&nbsp;&nbsp;&nbsp;\n' +
								'<a class="myHref" href="javascript:void(0);" onclick="deleteRemark(\''+data.remark.id+'\')"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #FF9797;"></span></a>\n' +
								'</div>\n' +
								'</div>\n' +
								'</div>')

						//清空备注框
						$("#remark").val("")
					}else {
						alert("添加备注失败");
					}
				}
			})
		})

		//更新备注按钮绑定事件
		$("#updateRemarkBtn").click(function () {
			var id = $("#remarkId").val();
			$.ajax({
				url : "workbench/activity/updateRemark.do",
				data : {"id" : id, "noteContent" : $("#noteContent").val()},
				type : "post",
				dataType : "json",
				success : function(data){
					if (data.success){
						//修改成功, 以不过后后端的形式刷新备注列表
						$("#content"+id).html(data.remark.noteContent);
						$("#small"+id).html(data.remark.editTime+" 由 "+data.remark.editBy)
						//关闭模态窗口
						$("#editRemarkModal").modal("hide");
					}else {
						alert("更新备注失败");
					}
				}
			})
		})

		showRemarkList();
	});

	function showRemarkList() {
		$.ajax({
			url : "workbench/activity/getActivityRemarkById.do",
			data : {"activityId": "${activity.id}"},
			dataType : "json",
			success : function(data){

				var aname = '${activity.name}';

				$.each(data,function (i,n) {
					$("#remarkDiv").before(
							'<div id="'+n.id+'" class="remarkDiv" style="height: 60px;">\n' +
							'<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">\n' +
							'<div style="position: relative; top: -40px; left: 40px;" >\n' +
							'<h5 id="content'+n.id+'">'+n.noteContent+'</h5>\n' +
							'<font color="gray">市场活动</font> <font color="gray">-</font> <b>'+aname+'</b> <small style="color: gray;" id="small'+n.id+'"> '+(n.editFlag==0? n.createTime : n.editTime)+' 由 '+(n.editFlag==0? n.createBy : n.editBy)+'</small>\n' +
							'<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">\n' +
							'<a class="myHref" href="javascript:void(0);" onclick="editRemark(\''+n.id+'\')"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #FF9797;"></span></a>\n' +
							'&nbsp;&nbsp;&nbsp;&nbsp;\n' +
							'<a class="myHref" href="javascript:void(0);" onclick="deleteRemark(\''+n.id+'\')"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #FF9797;"></span></a>\n' +
							'</div>\n' +
							'</div>\n' +
							'</div>')
				})
			}
		})
	}

	function deleteRemark(id) {
		if(confirm("确定删除该备注吗?")){
			$.ajax({
				url : "workbench/activity/deleteRemark.do",
				data : {"id" : id},
				type : "post",
				dataType : "json",
				success : function(data){
					if (data){
						//删除成功, 重新获取备注
						$("#"+id).remove();
					}else {
						alert("删除备注失败");
					}
				}
			})
		}
	}

	function editRemark(id) {
		//将id值赋给模态窗口的隐藏域
		$("#remarkId").val(id);
		//取出备注的值赋值给模态窗口
		$("#noteContent").val($("#content"+id).html());
		//展示模态窗口
		$("#editRemarkModal").modal("show");
	}
	
</script>

</head>
<body>
	
	<!-- 修改市场活动备注的模态窗口 -->
	<div class="modal fade" id="editRemarkModal" role="dialog">
		<%-- 备注的id --%>
		<input type="hidden" id="remarkId">
        <div class="modal-dialog" role="document" style="width: 40%;">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">
                        <span aria-hidden="true">×</span>
                    </button>
                    <h4 class="modal-title" id="myModalLabel">修改备注</h4>
                </div>
                <div class="modal-body">
                    <form class="form-horizontal" role="form">
                        <div class="form-group">
                            <label for="edit-describe" class="col-sm-2 control-label">内容</label>
                            <div class="col-sm-10" style="width: 81%;">
                                <textarea class="form-control" rows="3" id="noteContent"></textarea>
                            </div>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                    <button type="button" class="btn btn-primary" id="updateRemarkBtn">更新</button>
                </div>
            </div>
        </div>
    </div>

	<!-- 修改市场活动的模态窗口 -->
	<div class="modal fade" id="editActivityModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel2">修改市场活动</h4>
				</div>
				<div class="modal-body">

					<form class="form-horizontal" role="form">

						<div class="form-group">
							<label for="edit-marketActivityOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-owner">
									<!--ajax动态塞入数据-->
								</select>
							</div>
							<label for="edit-marketActivityName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-name" >
							</div>
						</div>

						<div class="form-group">
							<label for="edit-startTime" class="col-sm-2 control-label">开始日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control time" id="edit-startDate" readonly >
							</div>
							<label for="edit-endTime" class="col-sm-2 control-label">结束日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-endDate" readonly>
							</div>
						</div>

						<div class="form-group">
							<label for="edit-cost" class="col-sm-2 control-label">成本</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-cost" >
							</div>
						</div>

						<div class="form-group">
							<label for="edit-describe" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="edit-description"></textarea>
							</div>
						</div>

					</form>

				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="updateBtn">更新</button>
				</div>
			</div>
		</div>
	</div>

	<!-- 返回按钮 -->
	<div style="position: relative; top: 35px; left: 10px;">
		<a href="javascript:void(0);" onclick="window.history.back();"><span class="glyphicon glyphicon-arrow-left" style="font-size: 20px; color: #DDDDDD"></span></a>
	</div>
	
	<!-- 大标题 -->
	<div style="position: relative; left: 40px; top: -30px;">
		<div class="page-header">
			<h3>市场活动-${activity.name} <small>${activity.startDate} ~ ${activity.endDate}</small></h3>
		</div>
		<div style="position: relative; height: 50px; width: 250px;  top: -72px; left: 700px;">
			<button type="button" class="btn btn-default" data-toggle="modal" id="editBtn"><span class="glyphicon glyphicon-edit"></span> 编辑</button>
			<button type="button" class="btn btn-danger" id="deleteBtn"><span class="glyphicon glyphicon-minus"></span> 删除</button>
		</div>
	</div>
	
	<!-- 详细信息 -->
	<div style="position: relative; top: -70px;">
		<div style="position: relative; left: 40px; height: 30px;">
			<div style="width: 300px; color: gray;">所有者</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${activity.owner}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">名称</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${activity.name}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>

		<div style="position: relative; left: 40px; height: 30px; top: 10px;">
			<div style="width: 300px; color: gray;">开始日期</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${activity.startDate}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">结束日期</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${activity.endDate}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 20px;">
			<div style="width: 300px; color: gray;">成本</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${activity.cost}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 30px;">
			<div style="width: 300px; color: gray;">创建者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${activity.createBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${activity.createTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 40px;">
			<div style="width: 300px; color: gray;">修改者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${activity.editBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${activity.editTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 50px;">
			<div style="width: 300px; color: gray;">描述</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b>
					${activity.description}
				</b>
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
	</div>

	<!-- 备注 -->
	<div style="position: relative; top: 30px; left: 40px;" id="remarkBody" >
		<div class="page-header" id="forNewRemark">
			<h4>备注</h4>
		</div>
		<!--备注2
		<div class="remarkDiv" style="height: 60px;">
			<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
			<div style="position: relative; top: -40px; left: 40px;" >
				<h5>呵呵！</h5>
				<font color="gray">市场活动</font> <font color="gray">-</font> <b>发传单</b> <small style="color: gray;"> 2017-01-22 10:20:10 由zhangsan</small>
				<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>
					&nbsp;&nbsp;&nbsp;&nbsp;
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>
				</div>
			</div>
		</div>
		 -->
		<div id="remarkDiv" style="background-color: #E6E6E6; width: 870px; height: 90px;">
			<form role="form" style="position: relative;top: 10px; left: 10px;">
				<textarea id="remark" class="form-control" style="width: 850px; resize : none;" rows="2"  placeholder="添加备注..."></textarea>
				<p id="cancelAndSaveBtn" style="position: relative;left: 737px; top: 10px; display: none;">
					<button id="cancelBtn" type="button" class="btn btn-default">取消</button>
					<button type="button" class="btn btn-primary" id="saveRemark">保存</button>
				</p>
			</form>
		</div>
	</div>

	<div style="height: 200px;"></div>
</body>
</html>