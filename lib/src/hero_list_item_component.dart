import 'package:angular/angular.dart';
import 'package:angular_forms/angular_forms.dart';
import 'dart:html';
import 'hero.dart';
import 'package:dnd/dnd.dart';
import 'hero_service.dart';

@Component(
  selector: 'my-hero-item',
  template: '''
  <li class="sortable dragable" #sortable>
    <span class="badge">{{hero.id}}
    Favorite: <input type="checkbox" [(ngModel)]="hero.favorite" (change)="favoriteChange(hero.favorite)"/></span>
    <span class="elements" *ngIf="editable === false" >{{hero.name}}</span> 
    <span class="elements" *ngIf="editable === true" ><input type="text" [(ngModel)]="hero.name" placeholder="name" class="w3-input" /></span>
    <button class="elements" *ngIf="editable === false" (click)="editableName()">Edit</button>
    <button class="elements" *ngIf="editable === true" (click)="editableName()">Done</button>
    <span>Další pole</span>
  </li>
  ''',
  styleUrls: ['hero_list_item_component.css'],
  directives: [coreDirectives, formDirectives],
  pipes: [commonPipes],
)
class HeroListItemComponent implements  AfterViewInit{
  @Input()
  Hero hero;
  bool selected;
  bool editable = false;
  final HeroService _heroService;

  HeroListItemComponent(this._heroService);

  @ViewChild('sortable')
  HtmlElement item;

  @override
  void ngAfterViewInit() 
  {
    Draggable(item, avatarHandler: AvatarHandler.clone());

    Dropzone dropzone = Dropzone(item);

    dropzone.onDrop.listen((DropzoneEvent event) {
      swapElements(event.draggableElement, event.dropzoneElement);
    });
  }

  void editableName() {
    if (editable == true){
      save();
    }
    editable =!editable;   
  }

  void favoriteChange(favorite){
    print(favorite);
    //to-do zjistit zda onchange se neprovádí dřív než se změní hodnota v hero
    hero.favorite=!favorite;
    print(hero.favorite);
    save();
  }

  Future<void> save() async {
 
    await _heroService.update(hero);    
  }

  void swapElements(Element elm1, Element elm2) {
    var parent1 = elm1.parent;
    var next1 = elm1.nextElementSibling;
    var parent2 = elm2.parent;
    var next2 = elm2.nextElementSibling;

    parent1.insertBefore(elm2, next1);
    parent2.insertBefore(elm1, next2);
  }
}
