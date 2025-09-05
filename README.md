# Project 2-2
EST-iOS 4 2차 프로젝트

## ✔️커밋 컨벤션

```
- "태그: 제목" 의 형태이며, ":" 뒤에 space 가 있음에 유의합니다.
- 첫 글자는 "대문자" 로 작성해야 합니다.

Feat        : 새로운 기능 추가
Change      : 기능 변경 (코드 수정)
Fix         : 버그, 오류 수정
Design      : 사용자 UI 디자인 수정
Docs        : 문서 수정 (문서 추가, 수정, 삭제, README)
Init        : 프로젝트 생성
Rename      : 파일 혹은 폴더명을 수정하거나 옮기는 작업만 한 경우
Remove      : 파일 삭제
```

## ✔️코드 컨벤션 

- SSG (Swift Style Guide) 참고   
[StyleShare에서 작성한 Swift 한국어 스타일 가이드](https://github.com/StyleShare/swift-style-guide)


## ✔️브랜치 워크플로우

```
- 브랜치 네이밍 (Kebob case)

develop/feat/각자-맡은-기능명
(ex. develop/feat/collection-view) 


- 브랜치 워크플로우 ( Git - flow)
1. develop 브랜치에서 각자 feature 브랜치를 생성하여 작업합니다.
2. 기능 개발을 완료하면 Pull Request를 통해 feature 브랜치를 develop 브랜치에 병합합니다.
3. 로컬에서 최신 develop 브랜치를 pull 받고, 2~3을 반복합니다.
4. develop 브랜치에 코드가 어느 정도 합쳐졌다면 main 브랜치에 병합하여 배포합니다.
5. 1~4 과정을 반복합니다.
```
