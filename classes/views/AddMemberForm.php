<?php
class AddMemberForm extends Form {
	private $_footer;
	
	public function __construct(){
	}
	
	public function generateFooter(){
		$this->_footer = "<div style='margin-top:5px'><input type=\"submit\" value=\"Add New\">";
	}
	
	public function render(){
		$this->generateFooter();
		$output = '<form action="" method="post">';
		$output .='<div class="user-record";><table><thead><tr><th>Field</th><th>Value</th></tr></thead>';
		$label = "<tr><td>Member Name</td>";
		$info = "<td>" . Selections::renderHTML(Selections::DropDown, 'memberName', $this->getOptions('memberName')) . "</td></tr>";
		$output .=  ($label . $info);
		$output .= "</table></div>";
		$output .= $this->_footer . "<a href='index.php' style='margin-left:20px'>Back</a></form></div>";
		
		return $output;
	}
}