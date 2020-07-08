---
title: Hibernate で CHAR を String にマップする
date: 2019-02-04T20:01:19Z
# description: ""
# keywords: []
# authors: []
# categories: []
# series: []
tags: [hibernate, java]
# images: []
# videos: []
# audio: []
draft: false
---

例えば、生 JDBC で`char`型カラムのクエリを書くと`String`型にマップされます

        final Connection connection = DriverManager.getConnection(...);
        final Statement statement = connection.createStatement();
        final ResultSet resultSet = statement.executeQuery("select char_column from foo_table");

        // java.lang.String
        resultSet.getMetaData().getColumnClassName(1);

が、Hibernate の Native query を用いて同じように実行すると`Character`型にマップされます:

        final EntityManagerFactory factory = Persistence.createEntityManagerFactory(...);
        final EntityManager em = factory.createEntityManager();
        final Query q = em.createNativeQuery("select char_column from foo_table", Tuple.class);
        final List<Tuple> res = q.getResultList();

        // java.lang.Character
        res.get(0).get(0).getClass();

この挙動を決めているのは [`org.hibernate.dialect.Dialect`のこの辺り](https://github.com/hibernate/hibernate-orm/blob/5.4.1/hibernate-core/src/main/java/org/hibernate/dialect/Dialect.java#L221-L223)です:

    	registerHibernateType( Types.CHAR, StandardBasicTypes.CHARACTER.getName() );
    	registerHibernateType( Types.CHAR, 1, StandardBasicTypes.CHARACTER.getName() );
    	registerHibernateType( Types.CHAR, 255, StandardBasicTypes.STRING.getName() );

この挙動を変えるには、カスタムの Dialect を実装し、それを `persistence.xml` なりで指定するようにします。

カスタム Dialect の例:

    package com.example.dialect;

    import java.sql.Types;

    import org.hibernate.dialect.H2Dialect;
    import org.hibernate.type.StandardBasicTypes;

    public class H2CustomDialect extends H2Dialect {

        public H2CustomDialect() {
            super();

            registerHibernateType(Types.CHAR, StandardBasicTypes.STRING.getName());
            registerHibernateType(Types.CHAR, 1, StandardBasicTypes.STRING.getName());
            registerHibernateType(Types.CHAR, 255, StandardBasicTypes.STRING.getName());

        }

    }

参考:

- [HHH-2304 Wrong type detection for sql type char(x) columns](https://hibernate.atlassian.net/browse/HHH-2304)
- [JDBC API 入門 - 9. SQL と Java の型のマッピング](https://docs.oracle.com/javase/jp/1.5.0/guide/jdbc/getstart/mapping.html)
