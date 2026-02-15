---
title: "Eclipse"
date: 2020-07-26T02:45:24Z
draft: false
---

# dropins ディレクトリ構成パターン

参考: [The dropins folder and supported file layouts](http://help.eclipse.org/neon/index.jsp?topic=%2Forg.eclipse.platform.doc.isv%2Freference%2Fmisc%2Fp2_dropins_format.html)

     eclipse/
       dropins/
         org.eclipse.core.tools_1.4.0.200710121455.jar
         org.eclipse.releng.tools_3.3.0.v20070412/
           plugin.xml
           tools.jar
           ... etc ...
       ...

     eclipse/
       dropins/
         eclipse/
           features/
           plugins/

     eclipse/
       dropins/
         emf/
           eclipse/
             features/
             plugins/
         gef/
           eclipse/
             features/
             plugins/
         ... etc ...

# テンプレート変数

- [オフィシャルマニュアル](http://help.eclipse.org/neon/index.jsp?topic=%2Forg.eclipse.jdt.doc.user%2Fconcepts%2Fconcept-template-variables.htm)

- [日本語での説明](http://www.ibm.com/support/knowledgecenter/ja/SSQ2R2_9.1.1/org.eclipse.jdt.doc.user/concepts/concept-template-variables.htm)
