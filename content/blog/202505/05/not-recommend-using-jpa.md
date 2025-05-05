---
title: "JPAを積極的に推奨することはやめようと思う"
date: 2025-05-05T13:35:57+09:00
tags: ["java", "jpa"]
draft: false
---

```
@Transactional
public void updatePostTitle(Long postId, String postTitle) {
⠀
    Post post = postRepository.findById(postId).orElseThrow();
⠀
    post.setTitle(postTitle);
⠀
    postRepository.save(post);
}
```

これはHibernateのメインcontributorであるVlad Mihalceaさんのブログ記事 [The best Spring Data JpaRepository](https://vladmihalcea.com/best-spring-data-jparepository/) で "the save method anti-pattern" という名前の **アンチパターン** として紹介されているコードですが、今まで携わってきたプロジェクトでこのコードが間違っていると指摘できるプロジェクトはひとつもありませんでした。

これが理解できていないということは、[persistence context](https://jakarta.ee/specifications/persistence/3.2/jakarta-persistence-spec-3.2.html#overview)の概念も理解できていないはずで、その状態でJPAを触ると本当に間違いだらけの実装になります。

最近の人はおそらく最初にJPAを触る機会はSpring Bootで使うことになる[Spring Data JPA](https://spring.io/projects/spring-data-jpa)だと思うのですが、これも誤解を増幅させる機会になってしまっています。
**このライブラリーのJPAの利用方法は不適切です。**
この辺の話も[冒頭でリンクした記事](https://vladmihalcea.com/best-spring-data-jparepository/)で解説されています。

それ以外にも、JPAで利用するために適したテーブル定義方法というものはやっぱりあるがJPA実装担当者とテーブル設計担当者が異なっているが故にJPAから見て複雑なことをしないと実現できないようなテーブル設計になっていたりと、現実の現場では逆風が多いです。

まとめると、今まで携わったプロジェクトでまともにJPAを使えているプロジェクトは皆無でした。
また、現状、JPAに関する知識の無い人がまともに使えるような環境が無いです。

Spring Bootを使うなら、例えばSQLの知識が生かせる[MyBatis](https://mybatis.org/spring/ja/boot.html)とかで良いのではないでしょうか。
