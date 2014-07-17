import 'dart:html' as dom;
import 'dart:async' as async;
import 'package:quiver/collection.dart' as quiver;

void _streamSubtree(sc, dom.Element top) {
  for (var e in top.children) {
    sc.add(e);
    if(e.hasChildNodes()) {
      _streamSubtree(sc, e);
    }
  }
}

streamSubtree(dom.Element top) {
  var sc = new List<dom.Element>();
  _streamSubtree(sc, top);
  return sc;
}

class FormData extends quiver.DelegatingMap<String, String> {
  Map _submit = {};
  Map get submit => _submit;
  final Map<String, String> delegate = {};
  
  FormData(dom.FormElement form) {
    streamSubtree(form).forEach((dom.Element e) {
      if (!e.attributes.containsKey("name")) {
        return;
      }
      
      var type = e.nodeName.toUpperCase();
      if (type == "SELECT") {
        // pass
      } else if (type == "INPUT") {
        type = e.getAttribute("type").toUpperCase();
      } else {
        type = "TEXT";
      }
      var isFile = type == 'FILE';
      var isRadio = type == 'RADIO';
      var isCheckbox = type == 'CHECKBOX';
      var isSelect = type == 'SELECT';
      var isSubmit = type == 'SUBMIT';
      var isHidden = type == 'HIDDEN';
      
      if (isFile && e.files != null && e.files.length > 0) {
        throw 'File input not implemented'; //TODO
      } else if ((isRadio || isCheckbox) && !e.checked) {
        return;
      } else if (isSubmit) {
        _submit[e.getAttribute('name')] = e.getAttribute('value');
      } else if (isSelect){
        //print("+++\nselect\n+++");
        var option = e.querySelector('option[selected]');
        if (option == null) {
          option = e.querySelector('option');
        }
        var value = null;
        if (option != null) {
          value = option.getAttribute('value');
        }
        this[e.getAttribute('name')] = value;
      } else if (e.nodeName.toUpperCase() == 'INPUT' || e.nodeName.toUpperCase() == 'TEXTAREA') {
        this[e.getAttribute('name')] = e.getAttribute('value');
       //_submit.forEach((k, v) => print("$k, $v"));
        //print(this.length);
      } else {
//        print("\n\n\nELSE VETEV: ${e.nodeName} ${e.getAttribute("type")}\n\n\n");
      }
    });
  }
}

  /*\
  |*|
  |*|  :: XMLHttpRequest.prototype.sendAsBinary() Polyfill ::
  |*|
  |*|  https://developer.mozilla.org/en-US/docs/DOM/XMLHttpRequest#sendAsBinary()
  \*/

//  if (!XMLHttpRequest.prototype.sendAsBinary) {
//    XMLHttpRequest.prototype.sendAsBinary = function(sData) {
//      var nBytes = sData.length, ui8Data = new Uint8Array(nBytes);
//      for (var nIdx = 0; nIdx < nBytes; nIdx++) {
//        ui8Data[nIdx] = sData.charCodeAt(nIdx) & 0xff;
//      }
//      /* send as ArrayBufferView...: */
//      this.send(ui8Data);
//      /* ...or as ArrayBuffer (legacy)...: this.send(ui8Data.buffer); */
//    };
//  }

  /*\
  |*|
  |*|  :: AJAX Form Submit Framework ::
  |*|
  |*|  https://developer.mozilla.org/en-US/docs/DOM/XMLHttpRequest/Using_XMLHttpRequest
  |*|
  |*|  This framework is released under the GNU Public License, version 3 or later.
  |*|  http://www.gnu.org/licenses/gpl-3.0-standalone.html
  |*|
  |*|  Syntax:
  |*|
  |*|   AJAXSubmit(HTMLFormElement);
  \*/

//  class AJAXSubmit {
//    
//    var responseText;
//    var segmentIdx;
//    var owner;
//    var technique;
//
//    void ajaxSuccess () {
//      /* console.log("AJAXSubmit - Success!"); */
//      dom.window.alert(this.responseText);
//      /* you can get the serialized data through the "submittedData" custom property: */
//      /* alert(JSON.stringify(this.submittedData)); */
//    }
//
//    void submitData (oData) {
//      /* the AJAX request... */
//      var oAjaxReq = new XMLHttpRequest();
//      oAjaxReq.submittedData = oData;
//      oAjaxReq.onload = ajaxSuccess;
//      if (oData.technique == 0) {
//        /* method is GET */
//        oAjaxReq.open("get", oData.receiver.replace(/(?:\?.*)?$/, oData.segments.length > 0 ? "?" + oData.segments.join("&") : ""), true);
//        oAjaxReq.send(null);
//      } else {
//        /* method is POST */
//        oAjaxReq.open("post", oData.receiver, true);
//        if (oData.technique == 3) {
//          /* enctype is multipart/form-data */
//          var sBoundary = "---------------------------" + Date.now().toString(16);
//          oAjaxReq.setRequestHeader("Content-Type", "multipart\/form-data; boundary=" + sBoundary);
//          oAjaxReq.sendAsBinary("--" + sBoundary + "\r\n" + oData.segments.join("--" + sBoundary + "\r\n") + "--" + sBoundary + "--\r\n");
//        } else {
//          /* enctype is application/x-www-form-urlencoded or text/plain */
//          oAjaxReq.setRequestHeader("Content-Type", oData.contentType);
//          oAjaxReq.send(oData.segments.join(oData.technique == 2 ? "\r\n" : "&"));
//        }
//      }
//    }
//
//    void processStatus (oData) {
//      if (oData.status > 0) { return; }
//      /* the form is now totally serialized! do something before sending it to the server... */
//      /* doSomething(oData); */
//      /* console.log("AJAXSubmit - The form is now serialized. Submitting..."); */
//      submitData (oData);
//    }
//
//    void pushSegment (oFREvt) {
//      this.owner.segments[this.segmentIdx] += oFREvt.target.result + "\r\n";
//      this.owner.status--;
//      processStatus(this.owner);
//    }
//
//    String plainEscape (String sText) {
//      /* how should I treat a text/plain form encoding? what characters are not allowed? this is what I suppose...: */
//      /* "4\3\7 - Einstein said E=mc2" ----> "4\\3\\7\ -\ Einstein\ said\ E\=mc2" */
//      return sText.replace(/[\s\=\\]/g, "\\$&");
//    }
//
//    void SubmitRequest (oTarget) {
//      Map data = {};
//      
//      var nFile, sFieldType, oField, oSegmReq, oFile, bIsPost = oTarget.method.toLowerCase() == "post";
//      /* console.log("AJAXSubmit - Serializing form..."); */
//      this.contentType = bIsPost && oTarget.enctype ? oTarget.enctype : "application\/x-www-form-urlencoded";
//      this.technique = bIsPost ? this.contentType == "multipart\/form-data" ? 3 : this.contentType === "text\/plain" ? 2 : 1 : 0;
//      this.receiver = oTarget.action;
//      this.status = 0;
//      this.segments = [];
//      var fFilter = this.technique == 2 ? plainEscape : escape;
//      
//
//    return function (oFormElement) {
//      if (!oFormElement.action) { return; }
//      new SubmitRequest(oFormElement);
//    };
//}