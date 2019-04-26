# Install
```bash
$ pip install sqlalchemy mysql-connector
```

# Usage
```python
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import Column, Integer, String
from sqlalchemy.orm import sessionmaker

engine = create_engine('mysql+mysqlconnector://<user>:<password>@<host>[:<port>]/<dbname>')
Base = declarative_base()

class User(Base):
    __tablename__ = 'users'
    id = Column(Integer, primary_key=True)
    name = Column(String)
    fullname = Column(String)
    nickname = Column(String)
    def __repr__(self):
       return "<User(name='%s', fullname='%s', nickname='%s')>" % (
                            self.name, self.fullname, self.nickname)    
Session = sessionmaker(bind=engine)
session = Session()

```

# Relationship

## [Adjacency List Relationships (自关联表)](https://docs.sqlalchemy.org/en/13/orm/self_referential.html#adjacency-list-relationships)

example:  
```python
class Node(Base):
    __tablename__ = 'node'
    id = Column(Integer, primary_key=True)
    parent_id = Column(Integer, ForeignKey('node.id'))
    data = Column(String(50))
    parent = relationship("Node")
```

`relationship()` 默认设置为多对一关系, 在这种情况`parent = relationship("Node")`是不合适的, 要显式声明为一对多时
需要添加`remote_side`, 修改为:  
```python
class Node(Base):
    __tablename__ = 'node'
    id = Column(Integer, primary_key=True)
    parent_id = Column(Integer, ForeignKey('node.id'))
    data = Column(String(50))
    parent = relationship("Node", remote_side=[id])
```

双向关系建立使用`backref`  
```python
class Node(Base):
    __tablename__ = 'node'
    id = Column(Integer, primary_key=True)
    parent_id = Column(Integer, ForeignKey('node.id'))
    data = Column(String(50))
    children = relationship("Node",
                backref=backref('parent', remote_side=[id])
            )
```